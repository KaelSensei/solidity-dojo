// SPDX-License-Identifier: MIT
pragma solidity ^0.8.26;

/// @title IERC20StableSwap
/// @notice Minimal ERC20 interface for StableSwap AMM operations
interface IERC20StableSwap {
    function transfer(address to, uint256 amount) external returns (bool);
    function transferFrom(address from, address to, uint256 amount) external returns (bool);
    function balanceOf(address account) external view returns (uint256);
}

/// @title StableSwapAMM
/// @notice A simplified Curve-style StableSwap AMM for 2 tokens.
/// @dev Teaches the StableSwap invariant which combines constant-sum and constant-product
///      behaviour. Near the peg (equal balances), it behaves like x+y=k (low slippage).
///      Far from the peg, it approaches x*y=k (preventing reserve depletion).
///
///      The invariant for N=2 is:
///        A * 4 * (x + y) + D = A * D + D^3 / (4 * x * y)
///
///      where A is the amplification coefficient controlling how "flat" the curve is.
///      Higher A => more constant-sum-like (lower slippage near peg).
///      A = 0 degenerates to constant product. A = infinity degenerates to constant sum.
///
///      Newton's method is used to solve for D and y — max 255 iterations, sufficient
///      for convergence in practice.
contract StableSwapAMM {
    IERC20StableSwap public immutable token0;
    IERC20StableSwap public immutable token1;

    /// @notice Amplification coefficient (higher = flatter curve near peg)
    uint256 public immutable amplificationCoefficient;

    /// @notice Reserve of token0
    uint256 public reserve0;

    /// @notice Reserve of token1
    uint256 public reserve1;

    /// @notice Total LP shares outstanding
    uint256 public totalSupply;

    /// @notice LP shares per address
    mapping(address => uint256) public balanceOf;

    event Swap(address indexed user, address tokenIn, uint256 amountIn, uint256 amountOut);
    event AddLiquidity(address indexed user, uint256 amount0, uint256 amount1, uint256 shares);
    event RemoveLiquidity(address indexed user, uint256 shares, uint256 amount0, uint256 amount1);

    error InvalidToken();
    error ZeroAmount();
    error InsufficientLiquidity();
    error InsufficientShares();
    error ConvergenceFailed();
    error TransferFailed();

    uint256 private _unlocked = 1;
    modifier nonReentrant() {
        require(_unlocked == 1, "Reentrancy");
        _unlocked = 2;
        _;
        _unlocked = 1;
    }

    constructor(address token0Addr, address token1Addr, uint256 ampCoeff) {
        token0 = IERC20StableSwap(token0Addr);
        token1 = IERC20StableSwap(token1Addr);
        amplificationCoefficient = ampCoeff;
    }

    /// @notice Swap one token for the other using the StableSwap invariant
    /// @dev Computes D from current reserves, applies fee to input, then solves for new y.
    ///      amountOut = old_reserve_out - new_y.
    /// @return amountOut Amount of the other token received
    function swap(address tokenIn, uint256 amountIn) external nonReentrant returns (uint256 amountOut) {
        if (amountIn == 0) revert ZeroAmount();
        if (tokenIn != address(token0) && tokenIn != address(token1)) revert InvalidToken();

        bool isToken0 = tokenIn == address(token0);
        (IERC20StableSwap tokenInErc, IERC20StableSwap tokenOutErc, uint256 resInAmt, uint256 resOutAmt) = isToken0
            ? (token0, token1, reserve0, reserve1)
            : (token1, token0, reserve1, reserve0);

        if (!tokenInErc.transferFrom(msg.sender, address(this), amountIn)) revert TransferFailed();

        // Apply 0.3% fee to the input amount
        uint256 amountInWithFee = (amountIn * 997) / 1000;

        // Compute D from current reserves (before swap)
        uint256 d = _getD(resInAmt, resOutAmt);

        // New x after adding the input (with fee applied)
        uint256 newResIn = resInAmt + amountInWithFee;

        // Solve for the new y given the updated x and the same D
        uint256 newResOut = _getY(newResIn, d);

        amountOut = resOutAmt - newResOut;
        if (amountOut < 1) revert InsufficientLiquidity();

        if (!tokenOutErc.transfer(msg.sender, amountOut)) revert TransferFailed();

        _updateReserves();
        emit Swap(msg.sender, tokenIn, amountIn, amountOut);
    }

    /// @notice Add liquidity to the pool
    /// @return shares LP shares minted
    function addLiquidity(uint256 amount0, uint256 amount1) external nonReentrant returns (uint256 shares) {
        if (amount0 == 0 && amount1 == 0) revert ZeroAmount();

        if (amount0 > 0) {
            if (!token0.transferFrom(msg.sender, address(this), amount0)) revert TransferFailed();
        }
        if (amount1 > 0) {
            if (!token1.transferFrom(msg.sender, address(this), amount1)) revert TransferFailed();
        }

        if (totalSupply < 1) {
            // First deposit: compute D as the initial share basis
            uint256 d = _getD(amount0, amount1);
            shares = d;
        } else {
            // Compute D before and after deposit; shares proportional to D increase
            uint256 d0 = _getD(reserve0, reserve1);
            uint256 d1 = _getD(reserve0 + amount0, reserve1 + amount1);
            shares = ((d1 - d0) * totalSupply) / d0;
        }

        if (shares == 0) revert InsufficientLiquidity();

        balanceOf[msg.sender] += shares;
        totalSupply += shares;

        _updateReserves();
        emit AddLiquidity(msg.sender, amount0, amount1, shares);
    }

    /// @notice Remove liquidity from the pool
    /// @return amount0 Token0 returned
    /// @return amount1 Token1 returned
    function removeLiquidity(uint256 shares) external nonReentrant returns (uint256 amount0, uint256 amount1) {
        if (shares == 0) revert ZeroAmount();
        if (balanceOf[msg.sender] < shares) revert InsufficientShares();

        // Pro-rata share of each reserve
        amount0 = (shares * reserve0) / totalSupply;
        amount1 = (shares * reserve1) / totalSupply;

        balanceOf[msg.sender] -= shares;
        totalSupply -= shares;

        if (amount0 > 0) {
            if (!token0.transfer(msg.sender, amount0)) revert TransferFailed();
        }
        if (amount1 > 0) {
            if (!token1.transfer(msg.sender, amount1)) revert TransferFailed();
        }

        _updateReserves();
        emit RemoveLiquidity(msg.sender, shares, amount0, amount1);
    }

    /// @notice Compute D (the StableSwap invariant) for given reserves using Newton's method
    /// @dev Solves: amplificationCoefficient * 4 * S + D = amplificationCoefficient * D + D^3 / (4 * P)
    ///      where S = x + y, P = x * y, for N = 2.
    ///      Rearranged for Newton's iteration:
    ///        f(D)  = amplificationCoefficient*4*S + D - amplificationCoefficient*D - D^3/(4*P)  ... we want f(D) = 0  ... but easier to use
    ///        the standard Curve formulation:
    ///        D_{n+1} = (amplificationCoefficient * n * S + n * D_p) * D_n / ((amplificationCoefficient * n - 1) * D_n + (n+1) * D_p)
    ///        where D_p = D^n / (n^n * prod(x_i)) and n = 2
    /// @return d The invariant D
    function _getD(uint256 x, uint256 y) internal view returns (uint256 d) {
        uint256 s = x + y;
        if (s < 1) return 0;

        d = s; // Initial guess
        uint256 ann = amplificationCoefficient * 2; // amplificationCoefficient * n where n = 2

        for (uint256 i = 0; i < 255; i++) {
            // D_p = D^2 / (2 * x) * D / (2 * y) = D^3 / (4 * x * y)
            // Computed step by step to avoid overflow
            uint256 dP = d;
            dP = (dP * d) / (2 * x); // D^2 / (2x)
            dP = (dP * d) / (2 * y); // D^3 / (4xy)

            uint256 dPrev = d;

            // Newton step: D = (ann * S + 2 * dP) * D / ((ann - 1) * D + 3 * dP)
            // n = 2, so n*D_p = 2*dP and (n+1)*D_p = 3*dP
            uint256 numerator = (ann * s + 2 * dP) * d;
            uint256 denominator = (ann - 1) * d + 3 * dP;
            d = numerator / denominator;

            // Check convergence (within 1 wei)
            if (d > dPrev) {
                if (d - dPrev <= 1) return d;
            } else {
                if (dPrev - d <= 1) return d;
            }
        }

        revert ConvergenceFailed();
    }

    /// @notice Compute y given x and D using Newton's method
    /// @dev Solves for y in the StableSwap invariant given fixed x and D.
    ///      y_{n+1} = (y_n^2 + c) / (2 * y_n + b)
    ///      where c = D^3 / (4 * amplificationCoefficient * x) and b = D / (2*amplificationCoefficient) + x - D  ... but let's use the
    ///      standard Curve approach:
    ///        y^2 + (S' + D/(amplificationCoefficient*n) - D) * y = D^(n+1) / (n^n * amplificationCoefficient * n * prod_other_x)
    ///      For n=2, one other token x:
    ///        y^2 + (x + D/(2A) - D) * y = D^3 / (4 * 2A * x)
    /// @return y The computed reserve for the other token
    function _getY(uint256 x, uint256 d) internal view returns (uint256 y) {
        uint256 ann = amplificationCoefficient * 2; // amplificationCoefficient * n, n = 2

        // c = D^3 / (4 * x * ann)  — but compute step by step
        // c = D * D / (2 * x) * D / (2 * ann)  ... to keep intermediate sizes manageable
        uint256 c = (d * d) / (2 * x);
        c = (c * d) / (2 * ann);

        // b = x + D / ann - D
        // Note: b can be negative conceptually, so we handle carefully
        // In the iteration formula: y = (y^2 + c) / (2*y + b)
        // where b = x + D/ann - D
        // Rewrite: 2*y + b = 2*y + x + D/ann - D
        uint256 b = x + d / ann; // This is always > 0 for reasonable inputs

        y = d; // Initial guess
        for (uint256 i = 0; i < 255; i++) {
            uint256 yPrev = y;
            // y = (y^2 + c) / (2*y + b - D)
            // Note: (2*y + b) should be > D for convergence
            uint256 numerator = y * y + c;
            uint256 denominator = 2 * y + b - d;
            y = numerator / denominator;

            if (y > yPrev) {
                if (y - yPrev <= 1) return y;
            } else {
                if (yPrev - y <= 1) return y;
            }
        }

        revert ConvergenceFailed();
    }

    /// @dev Sync reserves with actual token balances
    function _updateReserves() private {
        reserve0 = token0.balanceOf(address(this));
        reserve1 = token1.balanceOf(address(this));
    }
}


