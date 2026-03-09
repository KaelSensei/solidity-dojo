// SPDX-License-Identifier: MIT
pragma solidity ^0.8.26;

/// @title TimeLock
/// @notice Timelock controller: queue transactions with a mandatory delay before execution.
/// @dev Commonly used in governance to give users time to exit before changes take effect.
contract TimeLock {
    /// @notice Minimum delay before execution (2 days)
    uint256 public constant MIN_DELAY = 2 days;

    /// @notice Maximum scheduling delay (30 days)
    uint256 public constant MAX_DELAY = 30 days;

    /// @notice Grace period after executeTime before tx expires (14 days)
    uint256 public constant GRACE_PERIOD = 14 days;

    /// @notice Contract owner
    address public immutable owner;

    /// @notice txId => queued status
    mapping(bytes32 => bool) public queued;

    event Queue(bytes32 indexed txId, address indexed target, uint256 value, bytes data, uint256 executeTime);
    event Execute(bytes32 indexed txId, address indexed target, uint256 value, bytes data, uint256 executeTime);
    event Cancel(bytes32 indexed txId);

    error NotOwner();
    error AlreadyQueued(bytes32 txId);
    error NotQueued(bytes32 txId);
    error TimestampNotInRange(uint256 executeTime, uint256 minTime, uint256 maxTime);
    error TimestampNotPassed(uint256 executeTime, uint256 currentTime);
    error TimestampExpired(uint256 executeTime, uint256 expiryTime);
    error ExecutionFailed();

    constructor() {
        owner = msg.sender;
    }

    receive() external payable {}

    modifier onlyOwner() {
        if (msg.sender != owner) revert NotOwner();
        _;
    }

    /// @notice Compute transaction ID from its parameters
    function getTxId(address target, uint256 value, bytes calldata data, uint256 executeTime)
        public
        pure
        returns (bytes32)
    {
        return keccak256(abi.encode(target, value, data, executeTime));
    }

    /// @notice Queue a transaction for delayed execution
    /// @param target Target contract address
    /// @param value ETH value to send
    /// @param data Calldata to execute
    /// @param executeTime Timestamp when the tx can be executed
    function queue(address target, uint256 value, bytes calldata data, uint256 executeTime)
        external
        onlyOwner
        returns (bytes32 txId)
    {
        txId = getTxId(target, value, data, executeTime);

        if (queued[txId]) revert AlreadyQueued(txId);
        if (executeTime < block.timestamp + MIN_DELAY || executeTime > block.timestamp + MAX_DELAY) {
            revert TimestampNotInRange(executeTime, block.timestamp + MIN_DELAY, block.timestamp + MAX_DELAY);
        }

        queued[txId] = true;
        emit Queue(txId, target, value, data, executeTime);
    }

    /// @notice Execute a queued transaction after its delay has passed
    function execute(address target, uint256 value, bytes calldata data, uint256 executeTime)
        external
        payable
        onlyOwner
    {
        bytes32 txId = getTxId(target, value, data, executeTime);

        if (!queued[txId]) revert NotQueued(txId);
        if (block.timestamp < executeTime) revert TimestampNotPassed(executeTime, block.timestamp);
        if (block.timestamp > executeTime + GRACE_PERIOD) revert TimestampExpired(executeTime, executeTime + GRACE_PERIOD);

        delete queued[txId];

        (bool success,) = target.call{value: value}(data);
        if (!success) revert ExecutionFailed();

        emit Execute(txId, target, value, data, executeTime);
    }

    /// @notice Cancel a queued transaction
    /// @param txId Transaction ID to cancel
    function cancel(bytes32 txId) external onlyOwner {
        if (!queued[txId]) revert NotQueued(txId);
        delete queued[txId];
        emit Cancel(txId);
    }
}

/// @title TimeLockTarget
/// @notice Simple target contract for TimeLock demonstrations
contract TimeLockTarget {
    uint256 public value;

    function setValue(uint256 _value) external {
        value = _value;
    }
}
