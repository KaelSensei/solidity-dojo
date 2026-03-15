// SPDX-License-Identifier: MIT
pragma solidity ^0.8.26;

import "forge-std/Test.sol";
import "src/applications/ERC20Permit.sol";

/// @title ERC20Permit Test Suite
contract ERC20PermitTest is Test {
    ERC20Permit public token;
    address public alice;
    uint256 public alicePrivateKey;
    address public bob = makeAddr("bob");
    address public relayer = makeAddr("relayer");

    function setUp() public {
        // Create alice with a known private key so we can sign messages
        (alice, alicePrivateKey) = makeAddrAndKey("alice");

        token = new ERC20Permit("PermitToken", "PT", 18);
        token.mint(alice, 1000e18);
    }

    /// @dev Helper to build and sign a permit
    function _signPermit(
        uint256 signerKey,
        address _owner,
        address spender,
        uint256 value,
        uint256 nonce,
        uint256 deadline
    ) internal view returns (uint8 v, bytes32 r, bytes32 s) {
        bytes32 structHash = keccak256(
            abi.encode(token.PERMIT_TYPEHASH(), _owner, spender, value, nonce, deadline)
        );
        bytes32 digest = keccak256(
            abi.encodePacked("\x19\x01", token.DOMAIN_SEPARATOR(), structHash)
        );
        (v, r, s) = vm.sign(signerKey, digest);
    }

    function test_PermitValidSignature() public {
        uint256 deadline = block.timestamp + 1 hours;
        uint256 amount = 500e18;

        (uint8 v, bytes32 r, bytes32 s) = _signPermit(
            alicePrivateKey, alice, bob, amount, 0, deadline
        );

        // Anyone can submit the permit (relayer pays gas)
        vm.prank(relayer);
        token.permit(alice, bob, amount, deadline, v, r, s);

        assertEq(token.allowance(alice, bob), amount, "Allowance should be set by permit");
    }

    function test_PermitExpiredDeadlineReverts() public {
        uint256 deadline = block.timestamp - 1; // Already expired
        uint256 amount = 500e18;

        (uint8 v, bytes32 r, bytes32 s) = _signPermit(
            alicePrivateKey, alice, bob, amount, 0, deadline
        );

        vm.expectRevert(
            abi.encodeWithSelector(ERC20Permit.ExpiredDeadline.selector, deadline, block.timestamp)
        );
        token.permit(alice, bob, amount, deadline, v, r, s);
    }

    function test_PermitWrongSignerReverts() public {
        uint256 deadline = block.timestamp + 1 hours;
        uint256 amount = 500e18;

        // Bob's private key signs, but we claim it's alice's permit
        (, uint256 bobPrivateKey) = makeAddrAndKey("bob_signer");
        (uint8 v, bytes32 r, bytes32 s) = _signPermit(
            bobPrivateKey, alice, bob, amount, 0, deadline
        );

        vm.expectRevert(ERC20Permit.InvalidSignature.selector);
        token.permit(alice, bob, amount, deadline, v, r, s);
    }

    function test_NonceIncrementsAfterPermit() public {
        uint256 deadline = block.timestamp + 1 hours;

        assertEq(token.nonces(alice), 0, "Nonce should start at 0");

        (uint8 v, bytes32 r, bytes32 s) = _signPermit(
            alicePrivateKey, alice, bob, 100e18, 0, deadline
        );
        token.permit(alice, bob, 100e18, deadline, v, r, s);

        assertEq(token.nonces(alice), 1, "Nonce should be 1 after first permit");

        // Sign with nonce 1 for the second permit
        (v, r, s) = _signPermit(alicePrivateKey, alice, bob, 200e18, 1, deadline);
        token.permit(alice, bob, 200e18, deadline, v, r, s);

        assertEq(token.nonces(alice), 2, "Nonce should be 2 after second permit");
    }

    function test_ReplayAttackReverts() public {
        uint256 deadline = block.timestamp + 1 hours;

        (uint8 v, bytes32 r, bytes32 s) = _signPermit(
            alicePrivateKey, alice, bob, 100e18, 0, deadline
        );

        token.permit(alice, bob, 100e18, deadline, v, r, s);

        // Same signature again should fail because nonce was incremented
        vm.expectRevert(ERC20Permit.InvalidSignature.selector);
        token.permit(alice, bob, 100e18, deadline, v, r, s);
    }

    function test_TransferFromAfterPermit() public {
        uint256 deadline = block.timestamp + 1 hours;
        uint256 amount = 300e18;

        (uint8 v, bytes32 r, bytes32 s) = _signPermit(
            alicePrivateKey, alice, bob, amount, 0, deadline
        );

        // Permit sets the allowance
        token.permit(alice, bob, amount, deadline, v, r, s);

        // Bob can now transferFrom without a separate approve tx
        vm.prank(bob);
        token.transferFrom(alice, bob, amount);

        assertEq(token.balanceOf(bob), amount, "Bob should have received tokens");
        assertEq(token.balanceOf(alice), 1000e18 - amount, "Alice balance should decrease");
    }

    function testFuzz_PermitAmount(uint256 amount) public {
        uint256 deadline = block.timestamp + 1 hours;

        (uint8 v, bytes32 r, bytes32 s) = _signPermit(
            alicePrivateKey, alice, bob, amount, 0, deadline
        );

        token.permit(alice, bob, amount, deadline, v, r, s);
        assertEq(token.allowance(alice, bob), amount);
    }
}
