// SPDX-License-Identifier: MIT
pragma solidity ^0.8.26;

/// @title SignatureReplay
/// @notice Demonstrates signature replay attacks
/// @dev Educational example - DO NOT USE IN PRODUCTION

/// @title Vulnerable Contract (VULNERABLE!)
contract VulnerableSignature {
    mapping(address => uint256) public nonces;
    
    /// @notice Transfer with signature - VULNERABLE to replay!
    function transferWithSignature(
        address to,
        uint256 amount,
        uint256 nonce,
        bytes calldata signature
    ) external {
        require(nonce == nonces[msg.sender], "Invalid nonce");
        
        bytes32 message = keccak256(abi.encodePacked(msg.sender, to, amount, nonce));
        require(_verify(message, signature), "Invalid signature");
        
        nonces[msg.sender]++;
        // Execute transfer
    }
    
    function _verify(bytes32 message, bytes calldata signature) internal pure returns (bool) {
        // Simplified - would use ecrecover in practice
        return signature.length == 65;
    }
}

/// @title Secure Contract with Domain Separator
contract SecureSignature {
    bytes32 public immutable DOMAIN_SEPARATOR;
    mapping(address => uint256) public nonces;
    
    constructor() {
        DOMAIN_SEPARATOR = keccak256(
            abi.encode(
                keccak256("EIP712Domain(string name,string version,uint256 chainId,address verifyingContract)"),
                keccak256("SecureSignature"),
                keccak256("1"),
                block.chainid,
                address(this)
            )
        );
    }
    
    /// @notice Transfer with signature - SECURE!
    function transferWithSignature(
        address to,
        uint256 amount,
        uint256 nonce,
        bytes calldata signature
    ) external {
        require(nonce == nonces[msg.sender], "Invalid nonce");
        
        bytes32 message = keccak256(
            abi.encodePacked(
                DOMAIN_SEPARATOR,
                keccak256(abi.encode(keccak256("Transfer(address to,uint256 amount,uint256 nonce)"), to, amount, nonce))
            )
        );
        
        require(_verify(message, signature), "Invalid signature");
        
        nonces[msg.sender]++;
    }
    
    function _verify(bytes32 message, bytes calldata signature) internal pure returns (bool) {
        return signature.length == 65;
    }
}

/// @title Cross-Chain Replay Vulnerable
contract CrossChainVulnerable {
    mapping(bytes32 => bool) public usedSignatures;
    
    function execute(
        bytes32 txHash,
        bytes calldata signature
    ) external {
        require(!usedSignatures[txHash], "Signature already used");
        
        // Verify signature and execute
        usedSignatures[txHash] = true;
    }
}
