// SPDX-License-Identifier: MIT
pragma solidity ^0.8.26;

import "forge-std/Test.sol";
import "src/hacks/FrontRunning.sol";

/// @title FrontRunning Test Suite
contract FrontRunningTest is Test {
    uint256 constant ANSWER = 42;
    bytes32 constant ANSWER_HASH = keccak256(abi.encodePacked(uint256(42)));

    address public alice = makeAddr("alice");
    address public bob = makeAddr("bob");

    // --- Vulnerable Game ---

    function test_VulnerableGameCanBeWon() public {
        VulnerableGuessGame game = new VulnerableGuessGame{value: 1 ether}(ANSWER_HASH);

        vm.prank(alice);
        game.guess(ANSWER);

        assertEq(alice.balance, 1 ether);
        assertEq(address(game).balance, 0);
    }

    function test_VulnerableGameWrongGuessReverts() public {
        VulnerableGuessGame game = new VulnerableGuessGame{value: 1 ether}(ANSWER_HASH);

        vm.prank(alice);
        vm.expectRevert(VulnerableGuessGame.WrongGuess.selector);
        game.guess(999);
    }

    // --- Secure Game (Commit-Reveal) ---

    function test_SecureGameCommitReveal() public {
        SecureGuessGame game = new SecureGuessGame{value: 1 ether}(
            ANSWER_HASH,
            1 hours,
            1 hours
        );

        bytes32 salt = keccak256("my-secret-salt");
        bytes32 commitment = keccak256(abi.encodePacked(uint256(42), salt));

        // Phase 1: Commit
        vm.prank(alice);
        game.commit(commitment);

        // Phase 2: Reveal (after commit deadline)
        vm.warp(block.timestamp + 1 hours + 1);
        vm.prank(alice);
        game.reveal(ANSWER, salt);

        assertEq(alice.balance, 1 ether);
    }

    function test_SecureGameWrongRevealFails() public {
        SecureGuessGame game = new SecureGuessGame{value: 1 ether}(
            ANSWER_HASH,
            1 hours,
            1 hours
        );

        bytes32 salt = keccak256("salt");
        bytes32 commitment = keccak256(abi.encodePacked(uint256(42), salt));

        vm.prank(alice);
        game.commit(commitment);

        vm.warp(block.timestamp + 1 hours + 1);

        // Wrong answer with right salt
        vm.prank(alice);
        vm.expectRevert(SecureGuessGame.NoCommitmentFound.selector);
        game.reveal(999, salt);
    }

    function test_SecureGameCannotRevealEarly() public {
        SecureGuessGame game = new SecureGuessGame{value: 1 ether}(
            ANSWER_HASH,
            1 hours,
            1 hours
        );

        bytes32 salt = keccak256("salt");
        bytes32 commitment = keccak256(abi.encodePacked(uint256(42), salt));

        vm.prank(alice);
        game.commit(commitment);

        vm.prank(alice);
        vm.expectRevert(SecureGuessGame.RevealPhaseNotOpen.selector);
        game.reveal(ANSWER, salt);
    }

    function test_SecureGameCannotCommitAfterDeadline() public {
        SecureGuessGame game = new SecureGuessGame{value: 1 ether}(
            ANSWER_HASH,
            1 hours,
            1 hours
        );

        vm.warp(block.timestamp + 2 hours);

        vm.prank(alice);
        vm.expectRevert(SecureGuessGame.CommitPhaseClosed.selector);
        game.commit(keccak256("late"));
    }

    function test_SecureGameCannotRevealAfterExpiry() public {
        SecureGuessGame game = new SecureGuessGame{value: 1 ether}(
            ANSWER_HASH,
            1 hours,
            1 hours
        );

        bytes32 salt = keccak256("salt");
        bytes32 commitment = keccak256(abi.encodePacked(uint256(42), salt));

        vm.prank(alice);
        game.commit(commitment);

        vm.warp(block.timestamp + 3 hours);

        vm.prank(alice);
        vm.expectRevert(SecureGuessGame.RevealPhaseClosed.selector);
        game.reveal(ANSWER, salt);
    }
}
