// SPDX-License-Identifier: MIT
pragma solidity ^0.8.26;

/// @title ERC20Permit
/// @notice ERC20 token with EIP-2612 gasless approval via off-chain signatures.
/// @dev Implements EIP-712 typed structured data hashing for the permit function.
///      This allows token holders to approve spenders without an on-chain transaction,
///      by signing a message that anyone can submit on their behalf.
contract ERC20Permit {
    // ─── ERC20 State ────────────────────────────────────────────────────

    string public name;
    string public symbol;
    uint8 public immutable decimals;
    uint256 public totalSupply;
    address public immutable owner;

    mapping(address => uint256) public balanceOf;
    mapping(address => mapping(address => uint256)) public allowance;

    // ─── EIP-2612 State ─────────────────────────────────────────────────

    /// @notice Nonce for each owner, incremented on each successful permit call
    /// @dev Prevents signature replay attacks
    mapping(address => uint256) public nonces;

    /// @notice EIP-712 domain separator, computed at deployment
    /// @dev Includes name, version, chainid, and contract address for domain binding
    bytes32 public immutable DOMAIN_SEPARATOR;

    /// @notice EIP-2612 permit typehash
    /// @dev keccak256("Permit(address owner,address spender,uint256 value,uint256 nonce,uint256 deadline)")
    bytes32 public constant PERMIT_TYPEHASH =
        keccak256("Permit(address owner,address spender,uint256 value,uint256 nonce,uint256 deadline)");

    // ─── Events ─────────────────────────────────────────────────────────

    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);

    // ─── Custom Errors ──────────────────────────────────────────────────

    error InsufficientBalance(uint256 available, uint256 required);
    error InsufficientAllowance(uint256 available, uint256 required);
    error ZeroAddress();
    error NotOwner();
    error ExpiredDeadline(uint256 deadline, uint256 currentTime);
    error InvalidSignature();

    // ─── Constructor ────────────────────────────────────────────────────

    /// @param _name Token name (also used in EIP-712 domain)
    /// @param _symbol Token symbol
    /// @param _decimals Token decimals
    constructor(string memory _name, string memory _symbol, uint8 _decimals) {
        name = _name;
        symbol = _symbol;
        decimals = _decimals;
        owner = msg.sender;

        // EIP-712 domain separator binds signatures to this specific contract and chain
        DOMAIN_SEPARATOR = keccak256(
            abi.encode(
                keccak256("EIP712Domain(string name,string version,uint256 chainId,address verifyingContract)"),
                keccak256(bytes(_name)),
                keccak256(bytes("1")),
                block.chainid,
                address(this)
            )
        );
    }

    // ─── ERC20 Functions ────────────────────────────────────────────────

    /// @notice Transfer tokens to a recipient
    /// @param to Recipient address
    /// @param amount Amount to transfer
    function transfer(address to, uint256 amount) external returns (bool) {
        if (to == address(0)) revert ZeroAddress();
        uint256 senderBal = balanceOf[msg.sender];
        if (senderBal < amount) revert InsufficientBalance(senderBal, amount);
        unchecked {
            balanceOf[msg.sender] = senderBal - amount;
        }
        balanceOf[to] += amount;
        emit Transfer(msg.sender, to, amount);
        return true;
    }

    /// @notice Approve a spender
    /// @param spender Address to authorize
    /// @param amount Maximum amount they can spend
    function approve(address spender, uint256 amount) external returns (bool) {
        allowance[msg.sender][spender] = amount;
        emit Approval(msg.sender, spender, amount);
        return true;
    }

    /// @notice Transfer tokens on behalf of an owner (requires prior approval)
    /// @param from Token owner
    /// @param to Recipient
    /// @param amount Amount to transfer
    function transferFrom(address from, address to, uint256 amount) external returns (bool) {
        if (to == address(0)) revert ZeroAddress();

        uint256 fromBal = balanceOf[from];
        uint256 currentAllowance = allowance[from][msg.sender];

        if (fromBal < amount) revert InsufficientBalance(fromBal, amount);
        if (currentAllowance < amount) revert InsufficientAllowance(currentAllowance, amount);

        unchecked {
            allowance[from][msg.sender] = currentAllowance - amount;
            balanceOf[from] = fromBal - amount;
        }
        balanceOf[to] += amount;
        emit Transfer(from, to, amount);
        return true;
    }

    /// @notice Mint new tokens (owner only)
    /// @param to Recipient of minted tokens
    /// @param amount Amount to mint
    function mint(address to, uint256 amount) external {
        if (msg.sender != owner) revert NotOwner();
        if (to == address(0)) revert ZeroAddress();
        totalSupply += amount;
        balanceOf[to] += amount;
        emit Transfer(address(0), to, amount);
    }

    // ─── EIP-2612 Permit ────────────────────────────────────────────────

    /// @notice Approve a spender via an off-chain signature (EIP-2612)
    /// @dev The signature must be from `_owner` and include the current nonce.
    ///      This enables gasless approvals: a relayer can submit the permit on
    ///      behalf of the token holder.
    /// @param _owner The token holder who signed the permit
    /// @param spender The address being approved to spend
    /// @param value The approval amount
    /// @param deadline Timestamp after which the signature expires
    /// @param v Recovery byte of the signature
    /// @param r First 32 bytes of the signature
    /// @param s Second 32 bytes of the signature
    function permit(
        address _owner,
        address spender,
        uint256 value,
        uint256 deadline,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) external {
        // Check deadline first
        if (block.timestamp > deadline) {
            revert ExpiredDeadline(deadline, block.timestamp);
        }

        // Build the EIP-712 struct hash for the Permit type
        bytes32 structHash = keccak256(
            abi.encode(PERMIT_TYPEHASH, _owner, spender, value, nonces[_owner], deadline)
        );

        // Build the full EIP-712 digest: "\x19\x01" || domainSeparator || structHash
        bytes32 digest = keccak256(
            abi.encodePacked("\x19\x01", DOMAIN_SEPARATOR, structHash)
        );

        // Recover signer from the signature
        address recoveredSigner = ecrecover(digest, v, r, s);

        // ecrecover returns address(0) for invalid signatures
        if (recoveredSigner == address(0) || recoveredSigner != _owner) {
            revert InvalidSignature();
        }

        // Increment nonce to prevent replay
        nonces[_owner]++;

        // Set the allowance
        allowance[_owner][spender] = value;
        emit Approval(_owner, spender, value);
    }
}
