// SPDX-License-Identifier: MIT
pragma solidity ^0.8.26;

import {Test} from "forge-std/Test.sol";
import {UserDefinedValueTypes} from "../../src/basic/UserDefinedValueTypes.sol";

contract UserDefinedValueTypesTest is Test {
    UserDefinedValueTypes public types;

    function setUp() public {
        types = new UserDefinedValueTypes();
    }

    /// @notice Unit test: wrap then unwrap returns original value
    function test_wrapUnwrap_roundtrip() public view {
        uint256 value = 100;
        assertEq(types.unwrapPrice(types.wrapPrice(value)), value);
        assertEq(types.unwrapQuantity(types.wrapQuantity(value)), value);
    }

    /// @notice Fuzz test: roundtrip is lossless for any value
    function testFuzz_wrap_unwrap(uint256 x) public view {
        assertEq(types.unwrapPrice(types.wrapPrice(x)), x);
        assertEq(types.unwrapQuantity(types.wrapQuantity(x)), x);
    }

    /// @notice Unit test: calculateTotal works correctly
    function test_calculateTotal() public view {
        uint256 price = 10;
        uint256 qty = 5;
        uint256 expected = price * qty; // 50

        UserDefinedValueTypes.Price p = types.wrapPrice(price);
        UserDefinedValueTypes.Quantity q = types.wrapQuantity(qty);
        UserDefinedValueTypes.Total t = types.calculateTotal(p, q);

        // Unwrap and verify
        assertEq(UserDefinedValueTypes.Total.unwrap(t), expected);
    }

    /// @notice Unit test: addPrices works correctly
    function test_addPrices() public view {
        UserDefinedValueTypes.Price a = types.wrapPrice(10);
        UserDefinedValueTypes.Price b = types.wrapPrice(20);

        UserDefinedValueTypes.Price sum = types.addPrices(a, b);
        assertEq(types.unwrapPrice(sum), 30);
    }

    /// @notice Unit test: pricesEqual works correctly
    function test_pricesEqual() public view {
        UserDefinedValueTypes.Price a = types.wrapPrice(10);
        UserDefinedValueTypes.Price b = types.wrapPrice(10);
        UserDefinedValueTypes.Price c = types.wrapPrice(20);

        assertTrue(types.pricesEqual(a, b));
        assertFalse(types.pricesEqual(a, c));
    }

    /// @notice Unit test: type safety - Price and Quantity are different types
    /// @dev This test demonstrates that Price and Quantity are distinct types
    ///      even though both wrap uint256
    function test_typeSafety() public view {
        // This is a compile-time check - Price and Quantity cannot be mixed
        // without explicit conversion
        UserDefinedValueTypes.Price price = types.wrapPrice(100);
        UserDefinedValueTypes.Quantity qty = types.wrapQuantity(5);

        // These are different types
        assertEq(types.unwrapPrice(price), 100);
        assertEq(types.unwrapQuantity(qty), 5);
    }
}
