// SPDX-License-Identifier: MIT
pragma solidity ^0.8.26;

/// @title WETHPermitAttack
/// @notice Demonstrates WETH permit griefing vulnerability
/// @dev Educational example - DO NOT USE IN PRODUCTION
///
/// Background:
/// - WETH (Wrapped Ether) at 0xC02aaA39b223FE8D0A0e5C4F27eAD9083C756Cc2 does NOT
///   implement EIP-2612 permit. It's a legacy contract from before EIP-2612 existed.
/// - Many protocols assume all ERC20 tokens support permit() for gasless approvals.
/// - Calling permit() on WETH reverts because the function doesn't exist.
///
/// Griefing attack:
/// - User signs a permit signature and submits a transaction calling depositWithPermit()
/// - Attacker sees the pending transaction in the mempool
/// - Attacker front-runs by extracting the permit params and calling permit() directly
/// - The permit executes (consuming the nonce)
/// - Victim's transaction arrives but permit() fails (nonce already used)
/// - Victim's entire transaction reverts
///
/// Prevention:
/// - Wrap permit() calls in try/catch
/// - Check allowance after failed permit — it may already be set
/// - Don't assume all ERC20s support permit

/// @notice Custom errors
error InsufficientBalance(address account, uint256 balance, uint256 amount);
error TransferFailed();
error PermitFailed();

/// @title SimpleWETH - minimal WETH implementation without permit
/// @notice Demonstrates that WETH does not have permit functionality
/// @dev Real WETH (0xC02...) is similarly a simple wrap/unwrap contract
///      that predates EIP-2612 and has no permit() function.
contract SimpleWETH {
    string public constant name = "Wrapped Ether";
    string public constant symbol = "WETH";
    uint8 public constant decimals = 18;

    mapping(address => uint256) public balanceOf;
    mapping(address => mapping(address => uint256)) public allowance;

    event Deposit(address indexed dst, uint256 wad);
    event Withdrawal(address indexed src, uint256 wad);
    event Transfer(address indexed from, address indexed to, uint256 amount);
    event Approval(address indexed owner, address indexed spender, uint256 amount);

    /// @notice Deposit ETH to receive WETH
    function deposit() external payable {
        balanceOf[msg.sender] += msg.value;
        emit Deposit(msg.sender, msg.value);
    }

    /// @notice Withdraw WETH to receive ETH
    /// @param amount The amount to withdraw
    function withdraw(uint256 amount) external {
        if (balanceOf[msg.sender] < amount) {
            revert InsufficientBalance(msg.sender, balanceOf[msg.sender], amount);
        }
        balanceOf[msg.sender] -= amount;
        (bool success,) = msg.sender.call{value: amount}("");
        if (!success) revert TransferFailed();
        emit Withdrawal(msg.sender, amount);
    }

    /// @notice Transfer WETH to another address
    /// @param to The recipient
    /// @param amount The amount to transfer
    /// @return success Always true if no revert
    function transfer(address to, uint256 amount) external returns (bool) {
        if (balanceOf[msg.sender] < amount) {
            revert InsufficientBalance(msg.sender, balanceOf[msg.sender], amount);
        }
        balanceOf[msg.sender] -= amount;
        balanceOf[to] += amount;
        emit Transfer(msg.sender, to, amount);
        return true;
    }

    /// @notice Approve a spender
    /// @param spender The address to approve
    /// @param amount The allowance amount
    /// @return success Always true
    function approve(address spender, uint256 amount) external returns (bool) {
        allowance[msg.sender][spender] = amount;
        emit Approval(msg.sender, spender, amount);
        return true;
    }

    /// @notice Transfer from another address using allowance
    /// @param from The source address
    /// @param to The destination address
    /// @param amount The amount to transfer
    /// @return success Always true if no revert
    function transferFrom(address from, address to, uint256 amount) external returns (bool) {
        if (allowance[from][msg.sender] < amount) {
            revert InsufficientBalance(from, allowance[from][msg.sender], amount);
        }
        if (balanceOf[from] < amount) {
            revert InsufficientBalance(from, balanceOf[from], amount);
        }
        allowance[from][msg.sender] -= amount;
        balanceOf[from] -= amount;
        balanceOf[to] += amount;
        emit Transfer(from, to, amount);
        return true;
    }

    /// @notice Accept ETH via receive
    receive() external payable {
        balanceOf[msg.sender] += msg.value;
        emit Deposit(msg.sender, msg.value);
    }

    // NOTE: No permit() function — just like real WETH
}

/// @title VulnerableVault - assumes all ERC20s support permit
/// @notice Tries to call permit on any token, breaks with WETH
/// @dev The depositWithPermit function assumes the token has permit().
///      This fails on WETH and any other token without EIP-2612 support.
contract VulnerableVault {
    SimpleWETH public immutable token;
    mapping(address => uint256) public deposits;

    constructor(address _token) {
        token = SimpleWETH(payable(_token));
    }

    /// @notice Deposit with permit (VULNERABLE - assumes token has permit)
    /// @dev This calls permit() on the token, which reverts for WETH.
    ///      Even for tokens WITH permit, this is vulnerable to front-running:
    ///      an attacker can extract the permit params from the mempool and
    ///      call permit() first, consuming the nonce and causing this tx to revert.
    /// @param amount The amount to deposit
    /// @param deadline Permit deadline
    /// @param v Signature v
    /// @param r Signature r
    /// @param s Signature s
    function depositWithPermit(
        uint256 amount,
        uint256 deadline,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) external {
        // This low-level call attempts to call permit() on the token.
        // For WETH: the function doesn't exist, so this reverts.
        // For tokens with permit: vulnerable to front-running.
        (bool success,) = address(token).call(
            abi.encodeWithSignature(
                "permit(address,address,uint256,uint256,uint8,bytes32,bytes32)",
                msg.sender,
                address(this),
                amount,
                deadline,
                v,
                r,
                s
            )
        );
        if (!success) revert PermitFailed();

        token.transferFrom(msg.sender, address(this), amount);
        deposits[msg.sender] += amount;
    }
}

/// @title SafeVault - handles permit failure gracefully
/// @notice Wraps permit in try/catch and falls back to existing allowance
/// @dev Prevention: always handle permit failure, check allowance as fallback
contract SafeVault {
    SimpleWETH public immutable token;
    mapping(address => uint256) public deposits;

    constructor(address _token) {
        token = SimpleWETH(payable(_token));
    }

    /// @notice Deposit with optional permit (SAFE - handles failure)
    /// @dev If permit fails (WETH, front-run, etc.), falls through to transferFrom.
    ///      The user must have already approved if permit doesn't work.
    /// @param amount The amount to deposit
    /// @param deadline Permit deadline (ignored if permit fails)
    /// @param v Signature v (ignored if permit fails)
    /// @param r Signature r (ignored if permit fails)
    /// @param s Signature s (ignored if permit fails)
    function depositWithPermit(
        uint256 amount,
        uint256 deadline,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) external {
        // Try permit — if it fails, that's OK. The user may have already approved,
        // or an attacker may have front-run the permit (which set the allowance anyway).
        // solhint-disable-next-line no-empty-blocks
        try this._callPermit(msg.sender, amount, deadline, v, r, s) {} catch {
            // Permit failed — continue anyway, transferFrom will use existing allowance.
            // If there's no allowance, transferFrom will revert with a clear error.
        }

        token.transferFrom(msg.sender, address(this), amount);
        deposits[msg.sender] += amount;
    }

    /// @notice Deposit with pre-existing approval (no permit needed)
    /// @param amount The amount to deposit
    function deposit(uint256 amount) external {
        token.transferFrom(msg.sender, address(this), amount);
        deposits[msg.sender] += amount;
    }

    /// @notice External helper to call permit (used with try/catch)
    /// @dev Must be external so try/catch works. Not meant for direct use.
    function _callPermit(
        address owner,
        uint256 amount,
        uint256 deadline,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) external {
        (bool success,) = address(token).call(
            abi.encodeWithSignature(
                "permit(address,address,uint256,uint256,uint8,bytes32,bytes32)",
                owner,
                address(this),
                amount,
                deadline,
                v,
                r,
                s
            )
        );
        if (!success) revert PermitFailed();
    }
}
