// SPDX-License-Identifier: MIT
pragma solidity ^0.8.26;

/// @title ERC1155Token
/// @notice Minimal ERC1155 multi-token implementation from scratch.
/// @dev Does NOT import OpenZeppelin. Implements the core ERC1155 interface manually.
///      Skips ERC1155Receiver callback checks for educational simplicity — in production
///      you must call onERC1155Received / onERC1155BatchReceived on the recipient if it
///      is a contract, per the ERC1155 spec.
contract ERC1155Token {
    // ─── State ──────────────────────────────────────────────────────────

    /// @notice Contract owner (can mint)
    address public immutable owner;

    /// @notice Token balances: account => token id => balance
    mapping(address => mapping(uint256 => uint256)) private _balances;

    /// @notice Operator approvals: owner => operator => approved
    mapping(address => mapping(address => bool)) private _operatorApprovals;

    // ─── Events (ERC1155 standard) ──────────────────────────────────────

    /// @notice Emitted on a single token transfer
    event TransferSingle(
        address indexed operator,
        address indexed from,
        address indexed to,
        uint256 id,
        uint256 amount
    );

    /// @notice Emitted on a batch token transfer
    event TransferBatch(
        address indexed operator,
        address indexed from,
        address indexed to,
        uint256[] ids,
        uint256[] amounts
    );

    /// @notice Emitted when an operator is approved or revoked
    event ApprovalForAll(address indexed account, address indexed operator, bool approved);

    // ─── Custom Errors ──────────────────────────────────────────────────

    error ZeroAddress();
    error InsufficientBalance(uint256 available, uint256 required);
    error NotApproved();
    error LengthMismatch(uint256 idsLength, uint256 amountsLength);
    error NotOwner();

    // ─── Constructor ────────────────────────────────────────────────────

    constructor() {
        owner = msg.sender;
    }

    // ─── View Functions ─────────────────────────────────────────────────

    /// @notice Get the balance of a single token for an account
    /// @return The token balance
    function balanceOf(address account, uint256 id) external view returns (uint256) {
        return _balances[account][id];
    }

    /// @notice Get balances for multiple account/id pairs
    /// @dev Arrays must have the same length
    /// @return balances Array of balances
    function balanceOfBatch(
        address[] calldata accounts,
        uint256[] calldata ids
    ) external view returns (uint256[] memory balances) {
        if (accounts.length != ids.length) {
            revert LengthMismatch(accounts.length, ids.length);
        }

        balances = new uint256[](accounts.length);
        for (uint256 i = 0; i < accounts.length; i++) {
            balances[i] = _balances[accounts[i]][ids[i]];
        }
    }

    /// @notice Check if an operator is approved for an account
    /// @return True if approved
    function isApprovedForAll(address account, address operator) external view returns (bool) {
        return _operatorApprovals[account][operator];
    }

    // ─── Write Functions ────────────────────────────────────────────────

    /// @notice Approve or revoke an operator for all your tokens
    function setApprovalForAll(address operator, bool approved) external {
        _operatorApprovals[msg.sender][operator] = approved;
        emit ApprovalForAll(msg.sender, operator, approved);
    }

    /// @notice Transfer a single token type
    /// @dev Caller must be the owner or an approved operator.
    ///      Skips ERC1155Receiver check (see contract-level @dev note).
    function safeTransferFrom(
        address from,
        address to,
        uint256 id,
        uint256 amount,
        bytes calldata data
    ) external {
        if (to == address(0)) revert ZeroAddress();
        if (from != msg.sender && !_operatorApprovals[from][msg.sender]) {
            revert NotApproved();
        }

        uint256 fromBal = _balances[from][id];
        if (fromBal < amount) revert InsufficientBalance(fromBal, amount);

        unchecked {
            _balances[from][id] = fromBal - amount;
        }
        _balances[to][id] += amount;

        // Suppress unused variable warning — data is part of the ERC1155 interface
        data;

        emit TransferSingle(msg.sender, from, to, id, amount);
    }

    /// @notice Transfer multiple token types in a single call
    /// @dev Caller must be the owner or an approved operator.
    ///      Skips ERC1155Receiver check (see contract-level @dev note).
    function safeBatchTransferFrom(
        address from,
        address to,
        uint256[] calldata ids,
        uint256[] calldata amounts,
        bytes calldata data
    ) external {
        if (to == address(0)) revert ZeroAddress();
        if (ids.length != amounts.length) revert LengthMismatch(ids.length, amounts.length);
        if (from != msg.sender && !_operatorApprovals[from][msg.sender]) {
            revert NotApproved();
        }

        for (uint256 i = 0; i < ids.length; i++) {
            uint256 id = ids[i];
            uint256 amount = amounts[i];
            uint256 fromBal = _balances[from][id];

            if (fromBal < amount) revert InsufficientBalance(fromBal, amount);

            unchecked {
                _balances[from][id] = fromBal - amount;
            }
            _balances[to][id] += amount;
        }

        // Suppress unused variable warning
        data;

        emit TransferBatch(msg.sender, from, to, ids, amounts);
    }

    /// @notice Mint a single token type (owner only)
    function mint(address to, uint256 id, uint256 amount) external {
        if (msg.sender != owner) revert NotOwner();
        if (to == address(0)) revert ZeroAddress();

        _balances[to][id] += amount;
        emit TransferSingle(msg.sender, address(0), to, id, amount);
    }

    /// @notice Mint multiple token types in a single call (owner only)
    function mintBatch(
        address to,
        uint256[] calldata ids,
        uint256[] calldata amounts
    ) external {
        if (msg.sender != owner) revert NotOwner();
        if (to == address(0)) revert ZeroAddress();
        if (ids.length != amounts.length) revert LengthMismatch(ids.length, amounts.length);

        for (uint256 i = 0; i < ids.length; i++) {
            _balances[to][ids[i]] += amounts[i];
        }

        emit TransferBatch(msg.sender, address(0), to, ids, amounts);
    }
}

