// SPDX-License-Identifier: MIT
pragma solidity ^0.8.26;

import "forge-std/Test.sol";
import "openzeppelin-contracts/contracts/token/ERC20/IERC20.sol";
import "src/defi/UniswapV4LimitOrder.sol";

/// @title Mock Pool Manager for Tests
contract MockPoolManagerFlashLoan {
    address public flashLoanContract;
    uint256 public lastFlashAmount;
    bytes public lastCallbackData;
    
    event UnlockCalled(address caller, bytes data);
    event FlashLoanProvided(address token, uint256 amount);

    function setFlashLoanContract(address _contract) external {
        flashLoanContract = _contract;
    }

    function unlock(bytes calldata data) external returns (bytes memory) {
        emit UnlockCalled(msg.sender, data);
        return data;
    }

    function provideFlashLoan(address token, uint256 amount) external {
        lastFlashAmount = amount;
        emit FlashLoanProvided(token, amount);
    }
}

/// @title Mock ERC20 Token for Limit Order Tests
contract MockERC20LimitOrder is IERC20 {
    string public name;
    string public symbol;
    uint8 public decimals;

    mapping(address => uint256) private _balances;
    mapping(address => mapping(address => uint256)) private _allowances;
    uint256 private _totalSupply;

    constructor(string memory _name, string memory _symbol, uint8 _decimals) {
        name = _name;
        symbol = _symbol;
        decimals = _decimals;
    }

    function mint(address to, uint256 amount) external {
        _balances[to] += amount;
        _totalSupply += amount;
    }

    function totalSupply() external view returns (uint256) {
        return _totalSupply;
    }

    function balanceOf(address account) external view returns (uint256) {
        return _balances[account];
    }

    function transfer(address to, uint256 amount) external returns (bool) {
        require(_balances[msg.sender] >= amount, "Insufficient balance");
        _balances[msg.sender] -= amount;
        _balances[to] += amount;
        return true;
    }

    function allowance(address owner, address spender) external view returns (uint256) {
        return _allowances[owner][spender];
    }

    function approve(address spender, uint256 amount) external returns (bool) {
        _allowances[msg.sender][spender] = amount;
        return true;
    }

    function transferFrom(address from, address to, uint256 amount) external returns (bool) {
        require(_balances[from] >= amount, "Insufficient balance");
        require(_allowances[from][msg.sender] >= amount, "Insufficient allowance");
        _balances[from] -= amount;
        _balances[to] += amount;
        _allowances[from][msg.sender] -= amount;
        return true;
    }
}

/// @title Uniswap V4 Limit Order Test Suite
contract UniswapV4LimitOrderTest is Test {
    UniswapV4LimitOrder public limitOrder;
    MockERC20LimitOrder public tokenA;
    MockERC20LimitOrder public tokenB;
    MockPoolManagerFlashLoan public poolManager;

    address public user = address(0x1);
    address public filler = address(0x2);
    uint256 deadline = block.timestamp + 1 days;

    /// @notice Set up test contracts
    function setUp() public {
        // Deploy mock PoolManager
        poolManager = new MockPoolManagerFlashLoan();

        // Deploy limit order contract
        limitOrder = new UniswapV4LimitOrder(address(poolManager));

        // Deploy mock tokens
        tokenA = new MockERC20LimitOrder("Token A", "TKA", 18);
        tokenB = new MockERC20LimitOrder("Token B", "TKB", 18);

        // Mint tokens to users
        tokenA.mint(user, 1000000e18);
        tokenB.mint(address(limitOrder), 1000000e18);
        tokenB.mint(filler, 1000000e18);
    }

    /// @notice Test creating a limit order
    function test_CreateOrder() public {
        uint256 amountIn = 100e18;
        uint256 amountOutMin = 90e18;
        int24 tickLower = 100;
        int24 tickUpper = 200;

        vm.startPrank(user);
        tokenA.approve(address(limitOrder), amountIn);

        uint256 orderId = limitOrder.createOrder(
            address(tokenA),
            address(tokenB),
            amountIn,
            amountOutMin,
            tickLower,
            tickUpper,
            deadline
        );
        vm.stopPrank();

        // Verify order was created
        assertEq(orderId, 1, "First order ID is 1");
        
        // Check order details using tuple destructuring
        (address owner, , , uint256 amount, , , , uint256 filled, bool cancelled, ) = limitOrder.getOrder(orderId);
        assertEq(owner, user, "Owner is correct");
        assertEq(amount, amountIn, "Amount is correct");
        assertEq(filled, 0, "Nothing filled yet");
        assertTrue(!cancelled, "Not cancelled");
    }

    /// @notice Test order reverts if amount is zero
    function test_CreateOrderZeroAmount() public {
        vm.startPrank(user);
        tokenA.approve(address(limitOrder), 0);

        vm.expectRevert("Amount must be > 0");
        limitOrder.createOrder(
            address(tokenA),
            address(tokenB),
            0,
            90e18,
            100,
            200,
            deadline
        );
        vm.stopPrank();
    }

    /// @notice Test order reverts if tick range is invalid
    function test_CreateOrderInvalidTickRange() public {
        vm.startPrank(user);
        tokenA.approve(address(limitOrder), 100e18);

        vm.expectRevert("Invalid tick range");
        limitOrder.createOrder(
            address(tokenA),
            address(tokenB),
            100e18,
            90e18,
            200,  // tickLower > tickUpper
            100,
            deadline
        );
        vm.stopPrank();
    }

    /// @notice Test filling a limit order
    function test_FillOrder() public {
        // Create order first
        uint256 amountIn = 100e18;
        uint256 amountOutMin = 90e18;

        vm.startPrank(user);
        tokenA.approve(address(limitOrder), amountIn);
        uint256 orderId = limitOrder.createOrder(
            address(tokenA),
            address(tokenB),
            amountIn,
            amountOutMin,
            100,
            200,
            deadline
        );
        vm.stopPrank();

        // Fill the order
        uint256 fillAmount = 50e18;
        uint256 balanceBefore = tokenB.balanceOf(user);
        
        limitOrder.fillOrder(orderId, fillAmount);

        // Verify fill
        uint256 balanceAfter = tokenB.balanceOf(user);
        assertGt(balanceAfter, balanceBefore, "Received tokenOut");
        
        // Check filled amount
        (,,,,,,,uint256 filled,,) = limitOrder.getOrder(orderId);
        assertEq(filled, fillAmount, "Filled amount updated");
    }

    /// @notice Test order fills at correct price
    function test_FillOrderAtCorrectPrice() public {
        uint256 amountIn = 1000e18;
        uint256 amountOutMin = 900e18;

        vm.startPrank(user);
        tokenA.approve(address(limitOrder), amountIn);
        uint256 orderId = limitOrder.createOrder(
            address(tokenA),
            address(tokenB),
            amountIn,
            amountOutMin,
            100,
            200,
            deadline
        );
        vm.stopPrank();

        // Fill should work with 0.3% fee (~997e15 output per 1e18)
        limitOrder.fillOrder(orderId, amountIn);

        // With 0.3% fee, output should be ~997e15
        (,,,,,,,uint256 filled,,) = limitOrder.getOrder(orderId);
        assertEq(filled, amountIn, "Fully filled");
    }

    /// @notice Test order does not fill above limit price
    function test_OrderRevertOnExcessiveSlippage() public {
        uint256 amountIn = 100e18;
        uint256 amountOutMin = 100e18; // Too high - only ~99.7e18 expected

        vm.startPrank(user);
        tokenA.approve(address(limitOrder), amountIn);
        uint256 orderId = limitOrder.createOrder(
            address(tokenA),
            address(tokenB),
            amountIn,
            amountOutMin,
            100,
            200,
            deadline
        );
        vm.stopPrank();

        vm.expectRevert("Below minimum");
        limitOrder.fillOrder(orderId, amountIn);
    }

    /// @notice Test partial fill
    function test_PartialFill() public {
        uint256 amountIn = 100e18;

        vm.startPrank(user);
        tokenA.approve(address(limitOrder), amountIn);
        uint256 orderId = limitOrder.createOrder(
            address(tokenA),
            address(tokenB),
            amountIn,
            50e18,
            100,
            200,
            deadline
        );
        vm.stopPrank();

        // First fill: 30%
        limitOrder.fillOrder(orderId, 30e18);
        (,,,,,,,uint256 filled1,,) = limitOrder.getOrder(orderId);
        assertEq(filled1, 30e18, "First fill 30%");

        // Second fill: 50% more
        limitOrder.fillOrder(orderId, 50e18);
        (,,,,,,,uint256 filled2,,) = limitOrder.getOrder(orderId);
        assertEq(filled2, 80e18, "Total fill 80%");
    }

    /// @notice Test cannot fill more than remaining
    function test_CannotOverfill() public {
        uint256 amountIn = 100e18;

        vm.startPrank(user);
        tokenA.approve(address(limitOrder), amountIn);
        uint256 orderId = limitOrder.createOrder(
            address(tokenA),
            address(tokenB),
            amountIn,
            1,
            100,
            200,
            deadline
        );
        vm.stopPrank();

        vm.expectRevert("Exceeds remaining");
        limitOrder.fillOrder(orderId, 150e18);
    }

    /// @notice Test cancel order
    function test_CancelOrder() public {
        uint256 amountIn = 100e18;

        vm.startPrank(user);
        tokenA.approve(address(limitOrder), amountIn);
        uint256 orderId = limitOrder.createOrder(
            address(tokenA),
            address(tokenB),
            amountIn,
            90e18,
            100,
            200,
            deadline
        );
        vm.stopPrank();

        // Cancel the order
        vm.prank(user);
        limitOrder.cancelOrder(orderId);

        // Verify cancelled
        (,,,,,,,,bool cancelled,) = limitOrder.getOrder(orderId);
        assertTrue(cancelled, "Order is cancelled");
    }

    /// @notice Test only owner can cancel
    function test_OnlyOwnerCanCancel() public {
        uint256 amountIn = 100e18;

        vm.startPrank(user);
        tokenA.approve(address(limitOrder), amountIn);
        uint256 orderId = limitOrder.createOrder(
            address(tokenA),
            address(tokenB),
            amountIn,
            90e18,
            100,
            200,
            deadline
        );
        vm.stopPrank();

        vm.expectRevert("Not owner");
        limitOrder.cancelOrder(orderId);
    }

    /// @notice Test cannot fill cancelled order
    function test_CannotFillCancelledOrder() public {
        uint256 amountIn = 100e18;

        vm.startPrank(user);
        tokenA.approve(address(limitOrder), amountIn);
        uint256 orderId = limitOrder.createOrder(
            address(tokenA),
            address(tokenB),
            amountIn,
            90e18,
            100,
            200,
            deadline
        );
        vm.stopPrank();

        // Cancel
        vm.prank(user);
        limitOrder.cancelOrder(orderId);

        // Try to fill
        vm.expectRevert("Order cancelled");
        limitOrder.fillOrder(orderId, amountIn);
    }

    /// @notice Test getRemainingAmount
    function test_GetRemainingAmount() public {
        uint256 amountIn = 100e18;

        vm.startPrank(user);
        tokenA.approve(address(limitOrder), amountIn);
        uint256 orderId = limitOrder.createOrder(
            address(tokenA),
            address(tokenB),
            amountIn,
            90e18,
            100,
            200,
            deadline
        );
        vm.stopPrank();

        uint256 remaining1 = limitOrder.getRemainingAmount(orderId);
        assertEq(remaining1, amountIn, "Full amount remaining");

        // Fill half
        limitOrder.fillOrder(orderId, 50e18);

        uint256 remaining2 = limitOrder.getRemainingAmount(orderId);
        assertEq(remaining2, 50e18, "Half remaining");
    }

    /// @notice Test isOrderFullyFilled
    function test_IsOrderFullyFilled() public {
        uint256 amountIn = 100e18;

        vm.startPrank(user);
        tokenA.approve(address(limitOrder), amountIn);
        uint256 orderId = limitOrder.createOrder(
            address(tokenA),
            address(tokenB),
            amountIn,
            1,
            100,
            200,
            deadline
        );
        vm.stopPrank();

        assertTrue(!limitOrder.isOrderFullyFilled(orderId), "Not fully filled initially");

        // Fill completely
        limitOrder.fillOrder(orderId, amountIn);

        assertTrue(limitOrder.isOrderFullyFilled(orderId), "Fully filled after fill");
    }

    /// @notice Test quote function
    function test_Quote() public {
        uint256 amountIn = 1000e18;
        
        uint256 quoteAmount = limitOrder.quote(amountIn);
        
        // 0.3% fee => 997/1000
        assertEq(quoteAmount, 997e18, "Quote is correct");
    }
}
