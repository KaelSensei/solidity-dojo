// SPDX-License-Identifier: MIT
pragma solidity ^0.8.26;

import "forge-std/Test.sol";
import "openzeppelin-contracts/contracts/token/ERC20/IERC20.sol";
import "src/defi/UniswapV4FlashLoan.sol";

/// @title Mock ERC20 Token for Flash Loan Tests
contract MockERC20FlashLoan is IERC20 {
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

    function burn(address from, uint256 amount) external {
        require(_balances[from] >= amount, "Insufficient balance");
        _balances[from] -= amount;
        _totalSupply -= amount;
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

/// @title Mock Callback Handler for Flash Loan Tests
contract MockFlashLoanCallback {
    bool public shouldFail;
    uint256 public flashAmount;
    address public flashToken;
    bytes public flashData;

    event CallbackExecuted(address token, uint256 amount, bytes data);

    constructor(bool _shouldFail) {
        shouldFail = _shouldFail;
    }

    function setCallbackData(uint256 amount, address token, bytes memory data) external {
        flashAmount = amount;
        flashToken = token;
        flashData = data;
    }

    function flashLoanCallback(address token, uint256 amount, bytes calldata data) external {
        emit CallbackExecuted(token, amount, data);
        
        if (shouldFail) {
            revert("Callback failed as requested");
        }
        
        // In real flash loan, you'd use the borrowed amount here
        // and then repay. For mock, we just emit the event.
        flashAmount = amount;
        flashToken = token;
        flashData = data;
    }
}

/// @title Mock Pool Manager for Flash Loan Tests
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
        
        // In production, this would handle the flash loan logic
        // For mock, we just return the data
        return data;
    }

    function provideFlashLoan(address token, uint256 amount) external {
        lastFlashAmount = amount;
        emit FlashLoanProvided(token, amount);
    }
}

/// @title Uniswap V4 Flash Loan Test Suite
contract UniswapV4FlashLoanTest is Test {
    event FlashLoanExecuted(address indexed borrower, address token, uint256 amount, uint256 fee);
    event CallbackExecuted(address token, uint256 amount, bytes data);

    UniswapV4FlashLoan public flashLoan;
    MockPoolManagerFlashLoan public poolManager;
    MockERC20FlashLoan public token;

    address public user = address(0x1);
    address public callbackContract = address(0x3);

    /// @notice Set up test contracts
    function setUp() public {
        // Deploy mock PoolManager
        poolManager = new MockPoolManagerFlashLoan();

        // Deploy flash loan contract
        flashLoan = new UniswapV4FlashLoan(address(poolManager));

        // Deploy mock token
        token = new MockERC20FlashLoan("Test Token", "TEST", 18);

        // Mint tokens
        token.mint(address(flashLoan), 1000000e18);
        token.mint(user, 1000000e18);
    }

    /// @notice Test flash loan executes correctly
    /// @dev This is a mock - it calculates and emits fees but doesn't actually borrow tokens
    function test_FlashLoanExecutes() public {
        uint256 amount = 100e18;
        
        // The mock calculates the fee and emits events but doesn't actually borrow tokens
        // We verify the function executes and the event is emitted
        vm.expectEmit(true, true, true, true);
        emit FlashLoanExecuted(msg.sender, address(token), amount, amount / 10000);
        flashLoan.executeFlashLoan(address(token), amount, "");
        
        // Verify fee calculation
        assertEq(flashLoan.calculateFee(amount), amount / 10000, "Fee calculated correctly");
    }

    /// @notice Test flash loan with callback executes
    /// @dev The mock calls the callback but doesn't actually provide flash liquidity
    function test_FlashLoanWithCallback() public {
        MockFlashLoanCallback callback = new MockFlashLoanCallback(false);
        
        uint256 amount = 50e18;
        bytes memory data = abi.encode("test data");
        
        // Expect the callback to be called
        vm.expectEmit(true, true, true, true);
        emit CallbackExecuted(address(token), amount, data);
        
        flashLoan.executeFlashLoanWithCallback(
            address(token),
            amount,
            address(callback),
            data
        );
        
        // Verify callback was called and stored the data
        assertEq(callback.flashAmount(), amount, "Callback received correct amount");
        assertEq(callback.flashToken(), address(token), "Callback received correct token");
    }

    /// @notice Test flash loan callback reverts when requested
    function test_FlashLoanCallbackFails() public {
        MockFlashLoanCallback callback = new MockFlashLoanCallback(true);
        
        uint256 amount = 50e18;
        bytes memory data = "";
        
        vm.expectRevert("Callback failed as requested");
        flashLoan.executeFlashLoanWithCallback(
            address(token),
            amount,
            address(callback),
            data
        );
    }

    /// @notice Test fee calculation
    function test_FeeCalculation() public {
        uint256 amount = 1000e18;
        uint256 expectedFee = amount / 10000; // 0.01%
        
        uint256 fee = flashLoan.calculateFee(amount);
        
        assertEq(fee, expectedFee, "Fee calculation is correct");
    }

    /// @notice Test different flash loan amounts
    function test_VariousFlashLoanAmounts() public {
        uint256[] memory amounts = new uint256[](3);
        amounts[0] = 1e18;
        amounts[1] = 100e18;
        amounts[2] = 1000e18;
        
        for (uint256 i = 0; i < amounts.length; i++) {
            uint256 expectedFee = amounts[i] / 10000;
            assertEq(flashLoan.calculateFee(amounts[i]), expectedFee);
        }
    }

    /// @notice Test pool manager address is set correctly
    function test_PoolManagerAddress() public {
        assertEq(flashLoan.poolManager(), address(poolManager));
        assertEq(flashLoan.getPoolManager(), address(poolManager));
    }

    /// @notice Test flash loan fee constant
    function test_FlashLoanFeeBPS() public {
        assertEq(flashLoan.FLASH_LOAN_FEE_BPS(), 1, "Fee is 1 bps");
    }

    /// @notice Test unlock callback can only be called by PoolManager
    function test_UnlockCallbackOnlyPoolManager() public {
        vm.expectRevert("Only PoolManager");
        flashLoan.unlockCallback(address(token), 100e18, 100e18 + 1e14, "");
    }

    /// @notice Test unlock callback succeeds when called by PoolManager
    function test_UnlockCallbackFromPoolManager() public {
        // This should succeed without reverting
        vm.prank(address(poolManager));
        flashLoan.unlockCallback(address(token), 100e18, 100e18 + 1e14, "test");
        
        // If we get here, the test passes
        assertTrue(true);
    }

    /// @notice Test multiple flash loans in sequence
    /// @dev Each call is independent - mock doesn't track state between calls
    function test_MultipleFlashLoans() public {
        uint256 amount1 = 10e18;
        uint256 amount2 = 20e18;
        uint256 amount3 = 30e18;
        
        // Each flash loan calculates its own fee independently
        // Verify fee calculations are correct
        assertEq(flashLoan.calculateFee(amount1), amount1 / 10000, "Fee 1 correct");
        assertEq(flashLoan.calculateFee(amount2), amount2 / 10000, "Fee 2 correct");
        assertEq(flashLoan.calculateFee(amount3), amount3 / 10000, "Fee 3 correct");
        
        // Execute each (mock doesn't track state)
        flashLoan.executeFlashLoan(address(token), amount1, "");
        flashLoan.executeFlashLoan(address(token), amount2, "");
        flashLoan.executeFlashLoan(address(token), amount3, "");
    }
}
