// SPDX-License-Identifier: MIT
pragma solidity ^0.8.26;

import "forge-std/Test.sol";
import "src/applications/UpgradeableProxy.sol";

/// @title UpgradeableProxy Test Suite
contract UpgradeableProxyTest is Test {
    UpgradeableProxy public proxy;
    CounterV1 public v1;
    CounterV2 public v2;

    event Upgraded(address indexed implementation);

    function setUp() public {
        v1 = new CounterV1();
        v2 = new CounterV2();
        proxy = new UpgradeableProxy(address(v1));
    }

    function test_InitialImplementation() public view {
        assertEq(proxy.implementation(), address(v1));
        assertEq(proxy.admin(), address(this));
    }

    function test_ProxyDelegatesToV1() public {
        CounterV1 counter = CounterV1(address(proxy));
        counter.increment();
        counter.increment();
        assertEq(counter.count(), 2);
        assertEq(counter.version(), 1);
    }

    function test_UpgradeChangesLogic() public {
        CounterV1 counterV1 = CounterV1(address(proxy));
        counterV1.increment();
        counterV1.increment();

        vm.expectEmit(true, false, false, false);
        emit Upgraded(address(v2));
        proxy.upgradeTo(address(v2));

        assertEq(proxy.implementation(), address(v2));
    }

    function test_StoragePersistsAfterUpgrade() public {
        CounterV1(address(proxy)).increment();
        CounterV1(address(proxy)).increment();
        CounterV1(address(proxy)).increment();

        proxy.upgradeTo(address(v2));

        CounterV2 counterV2 = CounterV2(address(proxy));
        assertEq(counterV2.count(), 3);
        assertEq(counterV2.version(), 2);
    }

    function test_V2HasNewFunctions() public {
        CounterV1(address(proxy)).increment();
        CounterV1(address(proxy)).increment();

        proxy.upgradeTo(address(v2));
        CounterV2 counterV2 = CounterV2(address(proxy));

        counterV2.decrement();
        assertEq(counterV2.count(), 1);

        counterV2.reset();
        assertEq(counterV2.count(), 0);
    }

    function test_OnlyAdminCanUpgrade() public {
        address notAdmin = makeAddr("notAdmin");
        vm.prank(notAdmin);
        vm.expectRevert(UpgradeableProxy.NotAdmin.selector);
        proxy.upgradeTo(address(v2));
    }

    function test_CannotUpgradeToInvalid() public {
        vm.expectRevert(UpgradeableProxy.InvalidImplementation.selector);
        proxy.upgradeTo(address(0));
    }

    function test_CannotUpgradeToEOA() public {
        vm.expectRevert(UpgradeableProxy.InvalidImplementation.selector);
        proxy.upgradeTo(makeAddr("eoa"));
    }
}
