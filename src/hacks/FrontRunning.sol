// SPDX-License-Identifier: MIT
pragma solidity ^0.8.26;

/// @title VulnerableGuessGame
/// @notice A guessing game vulnerable to front-running.
/// @dev The answer is checked against keccak256 of a public constant.
///      A front-runner can see the winning transaction in the mempool and submit
///      their own transaction with higher gas to claim the prize first.
contract VulnerableGuessGame {
    /// @notice Prize pool balance
    bytes32 public answerHash;

    event Winner(address indexed player, uint256 prize);

    error WrongGuess();
    error NoPrize();

    /// @param _answerHash keccak256 of the correct answer
    constructor(bytes32 _answerHash) payable {
        answerHash = _answerHash;
    }

    /// @notice Submit a guess — if correct, win the prize
    /// @dev VULNERABLE: the guess is visible in the mempool before mining
    function guess(uint256 _answer) external {
        if (keccak256(abi.encodePacked(_answer)) != answerHash) revert WrongGuess();

        uint256 prize = address(this).balance;
        if (prize == 0) revert NoPrize();

        (bool success,) = msg.sender.call{value: prize}("");
        require(success);
        emit Winner(msg.sender, prize);
    }
}

/// @title SecureGuessGame
/// @notice A guessing game protected against front-running using commit-reveal.
/// @dev Users first commit a hash of their answer + salt. After a delay, they reveal.
///      Front-runners cannot exploit the commitment because they don't know the answer
///      until the reveal phase, and they cannot commit fast enough.
contract SecureGuessGame {
    bytes32 public answerHash;
    uint256 public commitDeadline;
    uint256 public revealDeadline;

    /// @notice commitment => committer address
    mapping(bytes32 => address) public commitments;

    event CommitMade(address indexed player, bytes32 commitment);
    event Winner(address indexed player, uint256 prize);

    error WrongGuess();
    error NoPrize();
    error AlreadyCommitted();
    error CommitPhaseClosed();
    error RevealPhaseNotOpen();
    error RevealPhaseClosed();
    error NoCommitmentFound();

    /// @param _answerHash keccak256 of the correct answer
    /// @param _commitDuration Seconds the commit phase lasts
    /// @param _revealDuration Seconds the reveal phase lasts after commit ends
    constructor(bytes32 _answerHash, uint256 _commitDuration, uint256 _revealDuration) payable {
        answerHash = _answerHash;
        commitDeadline = block.timestamp + _commitDuration;
        revealDeadline = commitDeadline + _revealDuration;
    }

    /// @notice Phase 1: Commit a hash of (guess + salt)
    /// @param commitment keccak256(abi.encodePacked(guess, salt))
    function commit(bytes32 commitment) external {
        if (block.timestamp > commitDeadline) revert CommitPhaseClosed();
        if (commitments[commitment] != address(0)) revert AlreadyCommitted();

        commitments[commitment] = msg.sender;
        emit CommitMade(msg.sender, commitment);
    }

    /// @notice Phase 2: Reveal the answer and salt
    /// @param guess The guessed number
    /// @param salt Random salt used in the commitment
    function reveal(uint256 guess, bytes32 salt) external {
        if (block.timestamp <= commitDeadline) revert RevealPhaseNotOpen();
        if (block.timestamp > revealDeadline) revert RevealPhaseClosed();

        bytes32 commitment = keccak256(abi.encodePacked(guess, salt));
        if (commitments[commitment] != msg.sender) revert NoCommitmentFound();

        delete commitments[commitment];

        if (keccak256(abi.encodePacked(guess)) != answerHash) revert WrongGuess();

        uint256 prize = address(this).balance;
        if (prize == 0) revert NoPrize();

        (bool success,) = msg.sender.call{value: prize}("");
        require(success);
        emit Winner(msg.sender, prize);
    }
}
