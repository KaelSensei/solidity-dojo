// SPDX-License-Identifier: MIT
pragma solidity ^0.8.26;

import "forge-std/Test.sol";
import "src/evm/AssemblyBinaryExponentiation.sol";

/// @title Assembly Binary Exponentiation Test Suite
contract AssemblyBinaryExponentiationTest is Test {
    AssemblyBinaryExponentiation public asmPow;

    function setUp() public {
        asmPow = new AssemblyBinaryExponentiation();
    }

    /// @notice Test pow function
    function test_Pow() public {
        assertEq(asmPow.pow(2, 0), 1);
        assertEq(asmPow.pow(2, 1), 2);
        assertEq(asmPow.pow(2, 2), 4);
        assertEq(asmPow.pow(2, 10), 1024);
        assertEq(asmPow.pow(3, 3), 27);
        assertEq(asmPow.pow(5, 3), 125);
    }

    /// @notice Test power alias
    function test_Power() public {
        assertEq(asmPow.power(2, 8), 256);
        assertEq(asmPow.power(10, 3), 1000);
    }

    /// @notice Test square
    function test_Square() public {
        assertEq(asmPow.square(0), 0);
        assertEq(asmPow.square(1), 1);
        assertEq(asmPow.square(5), 25);
        assertEq(asmPow.square(10), 100);
    }

    /// @notice Test cube
    function test_Cube() public {
        assertEq(asmPow.cube(0), 0);
        assertEq(asmPow.cube(1), 1);
        assertEq(asmPow.cube(2), 8);
        assertEq(asmPow.cube(3), 27);
    }

    /// @notice Test pow2
    function test_Pow2() public {
        assertEq(asmPow.pow2(0), 1);
        assertEq(asmPow.pow2(1), 2);
        assertEq(asmPow.pow2(2), 4);
        assertEq(asmPow.pow2(8), 256);
        assertEq(asmPow.pow2(10), 1024);
    }

    /// @notice Test pow10
    function test_Pow10() public {
        assertEq(asmPow.pow10(0), 1);
        assertEq(asmPow.pow10(1), 10);
        assertEq(asmPow.pow10(2), 100);
        assertEq(asmPow.pow10(3), 1000);
    }

    /// @notice Test log2
    function test_Log2() public {
        assertEq(asmPow.log2(1), 0);
        assertEq(asmPow.log2(2), 1);
        assertEq(asmPow.log2(4), 2);
        assertEq(asmPow.log2(8), 3);
        assertEq(asmPow.log2(16), 4);
        assertEq(asmPow.log2(256), 8);
        assertEq(asmPow.log2(1024), 10);
    }

    /// @notice Test isPowerOfTwo
    function test_IsPowerOfTwo() public {
        assertTrue(asmPow.isPowerOfTwo(1));
        assertTrue(asmPow.isPowerOfTwo(2));
        assertTrue(asmPow.isPowerOfTwo(4));
        assertTrue(asmPow.isPowerOfTwo(8));
        assertTrue(asmPow.isPowerOfTwo(16));
        assertFalse(asmPow.isPowerOfTwo(3));
        assertFalse(asmPow.isPowerOfTwo(5));
        assertFalse(asmPow.isPowerOfTwo(6));
        assertFalse(asmPow.isPowerOfTwo(0));
    }

    /// @notice Test nextPowerOfTwo
    function test_NextPowerOfTwo() public {
        assertEq(asmPow.nextPowerOfTwo(0), 1);
        assertEq(asmPow.nextPowerOfTwo(1), 1);
        assertEq(asmPow.nextPowerOfTwo(2), 2);
        assertEq(asmPow.nextPowerOfTwo(3), 4);
        assertEq(asmPow.nextPowerOfTwo(4), 4);
        assertEq(asmPow.nextPowerOfTwo(5), 8);
        assertEq(asmPow.nextPowerOfTwo(15), 16);
        assertEq(asmPow.nextPowerOfTwo(16), 16);
    }

    /// @notice Test sqrt
    function test_Sqrt() public {
        assertEq(asmPow.sqrt(0), 0);
        assertEq(asmPow.sqrt(1), 1);
        assertEq(asmPow.sqrt(2), 1);
        assertEq(asmPow.sqrt(3), 1);
        assertEq(asmPow.sqrt(4), 2);
        assertEq(asmPow.sqrt(9), 3);
        assertEq(asmPow.sqrt(15), 3);
        assertEq(asmPow.sqrt(16), 4);
        assertEq(asmPow.sqrt(100), 10);
        assertEq(asmPow.sqrt(99), 9);
    }

    /// @notice Fuzz test pow
    function testFuzz_Pow(uint256 base, uint256 exp) public {
        exp = exp % 10;
        vm.assume(base <= 1000); // Bound to avoid overflow in expected calculation
        
        uint256 expected = 1;
        for (uint256 i = 0; i < exp; i++) {
            expected *= base;
        }
        
        assertEq(asmPow.pow(base, exp), expected);
    }

    /// @notice Fuzz test pow2
    function testFuzz_Pow2(uint256 n) public {
        n = n % 100;
        
        uint256 expected = 1;
        for (uint256 i = 0; i < n; i++) {
            expected *= 2;
        }
        
        assertEq(asmPow.pow2(n), expected);
    }

    /// @notice Fuzz test pow10
    function testFuzz_Pow10(uint256 n) public {
        n = n % 20;
        
        uint256 expected = 1;
        for (uint256 i = 0; i < n; i++) {
            expected *= 10;
        }
        
        assertEq(asmPow.pow10(n), expected);
    }

    /// @notice Fuzz test isPowerOfTwo
    function testFuzz_IsPowerOfTwo(uint256 x) public {
        vm.assume(x != 0); // Avoid underflow in (x - 1)
        bool isPow2 = (x & (x - 1)) == 0;
        
        bool result = asmPow.isPowerOfTwo(x);
        
        assertEq(result, isPow2);
    }

    /// @notice Fuzz test nextPowerOfTwo
    function testFuzz_NextPowerOfTwo(uint256 x) public {
        vm.assume(x <= (type(uint256).max >> 1) + 1); // Avoid overflow
        uint256 result = asmPow.nextPowerOfTwo(x);
        
        // Result should be >= x
        assertTrue(result >= x);
        
        // Result should be power of 2
        assertTrue(asmPow.isPowerOfTwo(result));
        
        // If x is already power of 2, result should equal x
        if (x > 0 && (x & (x - 1)) == 0) {
            assertEq(result, x);
        }
    }

    /// @notice Fuzz test sqrt
    function testFuzz_Sqrt(uint256 x) public {
        vm.assume(x < 2**128); // Keep result small to avoid (result+1)^2 overflow
        uint256 result = asmPow.sqrt(x);
        
        // result^2 should be <= x
        assertTrue(result * result <= x);
        
        // (result+1)^2 should be > x; skip if result+1 would overflow when squared
        if (result < 2**128 - 1) {
            uint256 next = result + 1;
            assertTrue(next * next > x);
        }
    }
}
