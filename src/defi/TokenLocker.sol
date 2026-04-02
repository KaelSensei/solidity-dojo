// SPDX-License-Identifier: MIT
pragma solidity ^0.8.26;

/// @title IERC20Locker
/// @notice Minimal ERC20 interface for token locking operations
interface IERC20Locker {
    function transfer(address to, uint256 amount) external returns (bool);
    function transferFrom(address from, address to, uint256 amount) external returns (bool);
}

/// @title TokenLocker
/// @notice A time-locked token vesting contract.
/// @dev Teaches time-based access control and struct-based state management.
///      Users create locks that hold tokens until a specified unlock time.
///      Only the designated beneficiary can withdraw, and only after the unlock time.
contract TokenLocker {
    /// @notice A single token lock
    struct Lock {
        address token;
        address beneficiary;
        uint256 amount;
        uint256 unlockTime;
        bool withdrawn;
    }

    /// @notice All locks indexed by ID
    Lock[] public locks;

    event LockCreated(
        uint256 indexed lockId,
        address indexed token,
        address indexed beneficiary,
        uint256 amount,
        uint256 unlockTime
    );
    event Withdrawn(uint256 indexed lockId, address indexed beneficiary, uint256 amount);

    error ZeroAmount();
    error ZeroAddress();
    error UnlockTimeInPast();
    error NotBeneficiary();
    error NotYetUnlocked();
    error AlreadyWithdrawn();
    error TransferFailed();

    /// @notice Create a new token lock
    /// @dev Transfers tokens from the caller into this contract and records the lock.
    ///      The beneficiary can withdraw only after unlockTime.
    /// @return lockId The ID of the newly created lock
    function createLock(
        address token,
        address beneficiary,
        uint256 amount,
        uint256 unlockTime
    ) external returns (uint256 lockId) {
        if (amount == 0) revert ZeroAmount();
        if (token == address(0)) revert ZeroAddress();
        if (beneficiary == address(0)) revert ZeroAddress();
        // slither-disable-next-line timestamp
        if (unlockTime <= block.timestamp) revert UnlockTimeInPast();

        lockId = locks.length;
        locks.push(Lock({
            token: token,
            beneficiary: beneficiary,
            amount: amount,
            unlockTime: unlockTime,
            withdrawn: false
        }));

        if (!IERC20Locker(token).transferFrom(msg.sender, address(this), amount)) revert TransferFailed();

        emit LockCreated(lockId, token, beneficiary, amount, unlockTime);
    }

    /// @notice Withdraw tokens from an expired lock
    /// @dev Only the beneficiary can call this, and only after the unlock time.
    function withdraw(uint256 lockId) external {
        Lock storage lock = locks[lockId];

        if (msg.sender != lock.beneficiary) revert NotBeneficiary();
        // slither-disable-next-line timestamp
        if (block.timestamp < lock.unlockTime) revert NotYetUnlocked();
        if (lock.withdrawn) revert AlreadyWithdrawn();

        lock.withdrawn = true;

        if (!IERC20Locker(lock.token).transfer(msg.sender, lock.amount)) revert TransferFailed();

        emit Withdrawn(lockId, msg.sender, lock.amount);
    }

    /// @notice Get the details of a lock
    /// @return token The locked token address
    /// @return beneficiary The beneficiary address
    /// @return amount The locked amount
    /// @return unlockTime The unlock timestamp
    /// @return withdrawn Whether the lock has been withdrawn
    function getLock(uint256 lockId)
        external
        view
        returns (
            address token,
            address beneficiary,
            uint256 amount,
            uint256 unlockTime,
            bool withdrawn
        )
    {
        Lock storage lock = locks[lockId];
        return (lock.token, lock.beneficiary, lock.amount, lock.unlockTime, lock.withdrawn);
    }

    /// @notice Total number of locks created
    /// @return The number of locks
    function lockCount() external view returns (uint256) {
        return locks.length;
    }
}

