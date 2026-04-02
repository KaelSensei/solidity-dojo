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
    /// @notice Address allowed to mint (deployer)
    address public immutable mintAuthority;

    mapping(address => uint256) public balanceOf;
    mapping(address => mapping(address => uint256)) public allowance;

    // ─── EIP-2612 State ─────────────────────────────────────────────────

    /// @notice Nonce for each owner, incremented on each successful permit call
    /// @dev Prevents signature replay attacks
    mapping(address => uint256) public nonces;

    /// @notice EIP-712 domain separator, computed at deployment
    /// @dev Includes name, version, chainid, and contract address for domain binding
    bytes32 public immutable domainSeparator;

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

    constructor(string memory _name, string memory _symbol, uint8 _decimals) {
        name = _name;
        symbol = _symbol;
        decimals = _decimals;
        mintAuthority = msg.sender;

        // EIP-712 domain separator binds signatures to this specific contract and chain
        domainSeparator = keccak256(
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
    function approve(address spender, uint256 amount) external returns (bool) {
        allowance[msg.sender][spender] = amount;
        emit Approval(msg.sender, spender, amount);
        return true;
    }

    /// @notice Transfer tokens on behalf of an owner (requires prior approval)
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
    function mint(address to, uint256 amount) external {
        if (msg.sender != mintAuthority) revert NotOwner();
        if (to == address(0)) revert ZeroAddress();
        totalSupply += amount;
        balanceOf[to] += amount;
        emit Transfer(address(0), to, amount);
    }

    // ─── EIP-2612 Permit ────────────────────────────────────────────────

    /// @notice Approve a spender via an off-chain signature (EIP-2612)
    /// @dev The signature must be from the `owner` argument and include the current nonce.
    ///      This enables gasless approvals: a relayer can submit the permit on
    ///      behalf of the token holder.
    function permit(
        address owner,
        address spender,
        uint256 value,
        uint256 deadline,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) external {
        // Check deadline first
        // slither-disable-next-line timestamp
        if (block.timestamp > deadline) {
            revert ExpiredDeadline(deadline, block.timestamp);
        }

        // Build the EIP-712 struct hash for the Permit type
        bytes32 structHash = keccak256(
            abi.encode(PERMIT_TYPEHASH, owner, spender, value, nonces[owner], deadline)
        );

        // Build the full EIP-712 digest: "\x19\x01" || domainSeparator || structHash
        bytes32 digest = keccak256(
            abi.encodePacked("\x19\x01", domainSeparator, structHash)
        );

        // Recover signer from the signature
        address recoveredSigner = ecrecover(digest, v, r, s);

        // ecrecover returns address(0) for invalid signatures
        if (recoveredSigner == address(0) || recoveredSigner != owner) {
            revert InvalidSignature();
        }

        // Increment nonce to prevent replay
        nonces[owner]++;

        // Set the allowance
        allowance[owner][spender] = value;
        emit Approval(owner, spender, value);
    }
}


