// SPDX-License-Identifier: MIT
pragma solidity ^0.8.26;

/// @title MultiSigWallet
/// @notice Gnosis-style multi-signature wallet with configurable threshold.
/// @dev Allows multiple owners to submit, approve, and execute transactions.
contract MultiSigWallet {
    /// @notice Event emitted when a transaction is submitted
    event SubmitTransaction(
        address indexed owner,
        uint256 indexed txIndex,
        address indexed to,
        uint256 value,
        bytes data
    );

    /// @notice Event emitted when an owner confirms a transaction
    event ConfirmTransaction(address indexed owner, uint256 indexed txIndex);

    /// @notice Event emitted when an owner revokes their confirmation
    event RevokeConfirmation(address indexed owner, uint256 indexed txIndex);

    /// @notice Event emitted when a transaction is executed
    event ExecuteTransaction(address indexed owner, uint256 indexed txIndex);

    /// @notice Event emitted when an owner is added
    event OwnerAdded(address indexed owner);

    /// @notice Event emitted when an owner is removed
    event OwnerRemoved(address indexed owner);

    /// @notice Event emitted when the threshold is changed
    event ThresholdChanged(uint256 threshold);

    /// @notice Thrown when a transaction does not exist
    error TxDoesNotExist(uint256 txIndex);

    /// @notice Thrown when a transaction has already been executed
    error TxAlreadyExecuted(uint256 txIndex);

    /// @notice Thrown when the transaction execution fails
    error TxExecutionFailed(uint256 txIndex);

    /// @notice Thrown when caller is not an owner
    error NotOwner(address caller);

    /// @notice Thrown when caller is already an owner
    error AlreadyOwner(address owner);

    /// @notice Thrown when caller is not an owner (for removal)
    error NotAnOwner(address owner);

    /// @notice Thrown when trying to remove an owner that would break threshold
    error InvalidThreshold(uint256 threshold, uint256 owners);

    /// @notice Thrown when the threshold is zero
    error ZeroThreshold();

    /// @notice Thrown when the number of owners is too small
    error TooFewOwners(uint256 owners);

    /// @notice Struct representing a transaction
    struct Transaction {
        address to;
        uint256 value;
        bytes data;
        bool executed;
        uint256 numConfirmations;
    }

    /// @notice Array of owner addresses
    address[] public owners;

    /// @notice Mapping to check if an address is an owner
    mapping(address => bool) public isOwner;

    /// @notice Required number of confirmations to execute a transaction
    uint256 public threshold;

    /// @notice Mapping from tx index to Transaction
    mapping(uint256 => Transaction) public transactions;

    /// @notice Mapping from tx index to owner confirmations
    mapping(uint256 => mapping(address => bool)) public confirmations;

    /// @notice Number of transactions
    uint256 public txCount;

    /// @notice Modifier to check if caller is an owner
    modifier onlyOwner() {
        if (!isOwner[msg.sender]) revert NotOwner(msg.sender);
        _;
    }

    /// @notice Modifier to check if transaction exists
    modifier txExists(uint256 _txIndex) {
        if (_txIndex >= txCount) revert TxDoesNotExist(_txIndex);
        _;
    }

    /// @notice Modifier to check if transaction is not executed
    modifier notExecuted(uint256 _txIndex) {
        if (transactions[_txIndex].executed) revert TxAlreadyExecuted(_txIndex);
        _;
    }

    /// @notice Modifier to check if owner has not confirmed
    modifier notConfirmed(uint256 _txIndex) {
        if (confirmations[_txIndex][msg.sender]) revert AlreadyConfirmed(msg.sender);
        _;
    }

    /// @notice Thrown when owner has already confirmed
    error AlreadyConfirmed(address owner);

    /// @notice Constructor - sets initial owners and threshold
    /// @param _owners Array of initial owner addresses
    /// @param _threshold Required number of confirmations
    constructor(address[] memory _owners, uint256 _threshold) {
        if (_threshold == 0) revert ZeroThreshold();
        if (_owners.length < _threshold) revert TooFewOwners(_owners.length);
        if (_owners.length > 10) revert TooManyOwners(_owners.length);

        for (uint256 i = 0; i < _owners.length;) {
            address owner = _owners[i];
            if (owner == address(0)) revert ZeroAddress();
            if (isOwner[owner]) revert AlreadyOwner(owner);

            isOwner[owner] = true;
            owners.push(owner);
            unchecked { ++i; }
        }

        threshold = _threshold;
        emit ThresholdChanged(_threshold);
    }

    /// @notice Thrown when too many owners
    error TooManyOwners(uint256 owners);

    /// @notice Thrown when address is zero
    error ZeroAddress();

    /// @notice Submit a new transaction
    /// @param _to Target contract address
    /// @param _value Ether value to send
    /// @param _data Transaction data
    /// @return txIndex Index of the new transaction
    function submitTransaction(
        address _to,
        uint256 _value,
        bytes calldata _data
    ) public onlyOwner returns (uint256 txIndex) {
        txIndex = txCount;

        transactions[txIndex] = Transaction({
            to: _to,
            value: _value,
            data: _data,
            executed: false,
            numConfirmations: 0
        });

        txCount++;

        emit SubmitTransaction(msg.sender, txIndex, _to, _value, _data);
    }

    /// @notice Confirm a transaction
    /// @param _txIndex Transaction index to confirm
    function confirmTransaction(
        uint256 _txIndex
    ) public onlyOwner txExists(_txIndex) notExecuted(_txIndex) notConfirmed(_txIndex) {
        Transaction storage transaction = transactions[_txIndex];
        transaction.numConfirmations++;
        confirmations[_txIndex][msg.sender] = true;

        emit ConfirmTransaction(msg.sender, _txIndex);
    }

    /// @notice Revoke confirmation for a transaction
    /// @param _txIndex Transaction index to revoke
    function revokeConfirmation(
        uint256 _txIndex
    ) public onlyOwner txExists(_txIndex) notExecuted(_txIndex) {
        if (!confirmations[_txIndex][msg.sender]) revert NotConfirmed(msg.sender);

        Transaction storage transaction = transactions[_txIndex];
        transaction.numConfirmations--;
        confirmations[_txIndex][msg.sender] = false;

        emit RevokeConfirmation(msg.sender, _txIndex);
    }

    /// @notice Thrown when transaction is not confirmed by sender
    error NotConfirmed(address owner);

    /// @notice Execute a confirmed transaction
    /// @param _txIndex Transaction index to execute
    function executeTransaction(
        uint256 _txIndex
    ) public onlyOwner txExists(_txIndex) notExecuted(_txIndex) {
        Transaction storage transaction = transactions[_txIndex];

        if (transaction.numConfirmations < threshold) revert InsufficientConfirmations(_txIndex);

        transaction.executed = true;

        (bool success, ) = transaction.to.call{value: transaction.value}(
            transaction.data
        );

        if (!success) revert TxExecutionFailed(_txIndex);

        emit ExecuteTransaction(msg.sender, _txIndex);
    }

    /// @notice Thrown when there are insufficient confirmations
    error InsufficientConfirmations(uint256 txIndex);

    /// @notice Get the list of owners
    /// @return Array of owner addresses
    function getOwners() public view returns (address[] memory) {
        return owners;
    }

    /// @notice Get transaction details
    /// @param _txIndex Transaction index
    /// @return to Target address
    /// @return value Ether value
    /// @return data Transaction data
    /// @return executed Whether transaction is executed
    /// @return numConfirmations Number of confirmations
    function getTransaction(
        uint256 _txIndex
    )
        public
        view
        returns (
            address to,
            uint256 value,
            bytes memory data,
            bool executed,
            uint256 numConfirmations
        )
    {
        Transaction storage transaction = transactions[_txIndex];
        return (
            transaction.to,
            transaction.value,
            transaction.data,
            transaction.executed,
            transaction.numConfirmations
        );
    }

    /// @notice Get confirmation status for a transaction
    /// @param _txIndex Transaction index
    /// @param _owner Owner address to check
    /// @return Whether the owner has confirmed
    function getConfirmation(
        uint256 _txIndex,
        address _owner
    ) public view returns (bool) {
        return confirmations[_txIndex][_owner];
    }

    /// @notice Receive ether
    receive() external payable {}
}
