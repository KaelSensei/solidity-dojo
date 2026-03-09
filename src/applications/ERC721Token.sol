// SPDX-License-Identifier: MIT
pragma solidity ^0.8.26;

/// @title IERC721Receiver
/// @notice Interface for contracts that want to receive ERC721 tokens via safeTransfer
interface IERC721Receiver {
    function onERC721Received(address operator, address from, uint256 tokenId, bytes calldata data)
        external
        returns (bytes4);
}

/// @title ERC721Token
/// @notice Minimal ERC721 (NFT) implementation from scratch.
/// @dev Implements ownerOf, balanceOf, transfer, approve, and safe transfer with receiver checks.
contract ERC721Token {
    /// @notice Token name
    string public name;

    /// @notice Token symbol
    string public symbol;

    /// @notice Contract owner (can mint)
    address public immutable owner;

    /// @notice Token ID => owner address
    mapping(uint256 => address) public ownerOf;

    /// @notice Owner address => token count
    mapping(address => uint256) public balanceOf;

    /// @notice Token ID => approved address
    mapping(uint256 => address) public getApproved;

    /// @notice Owner => operator => approved for all
    mapping(address => mapping(address => bool)) public isApprovedForAll;

    event Transfer(address indexed from, address indexed to, uint256 indexed tokenId);
    event Approval(address indexed owner, address indexed approved, uint256 indexed tokenId);
    event ApprovalForAll(address indexed owner, address indexed operator, bool approved);

    error NotOwnerOrApproved();
    error ZeroAddress();
    error TokenAlreadyMinted(uint256 tokenId);
    error TokenDoesNotExist(uint256 tokenId);
    error NotOwner();
    error UnsafeRecipient();

    constructor(string memory _name, string memory _symbol) {
        name = _name;
        symbol = _symbol;
        owner = msg.sender;
    }

    /// @notice Check if a token exists
    function _exists(uint256 tokenId) internal view returns (bool) {
        return ownerOf[tokenId] != address(0);
    }

    /// @notice Check if caller is owner or approved
    function _isApprovedOrOwner(address spender, uint256 tokenId) internal view returns (bool) {
        address tokenOwner = ownerOf[tokenId];
        return (spender == tokenOwner || getApproved[tokenId] == spender || isApprovedForAll[tokenOwner][spender]);
    }

    /// @notice Mint a new token
    /// @param to Recipient address
    /// @param tokenId Token ID to mint
    function mint(address to, uint256 tokenId) external {
        if (msg.sender != owner) revert NotOwner();
        if (to == address(0)) revert ZeroAddress();
        if (_exists(tokenId)) revert TokenAlreadyMinted(tokenId);

        balanceOf[to]++;
        ownerOf[tokenId] = to;
        emit Transfer(address(0), to, tokenId);
    }

    /// @notice Burn a token
    /// @param tokenId Token ID to burn
    function burn(uint256 tokenId) external {
        address tokenOwner = ownerOf[tokenId];
        if (!_exists(tokenId)) revert TokenDoesNotExist(tokenId);
        if (!_isApprovedOrOwner(msg.sender, tokenId)) revert NotOwnerOrApproved();

        delete getApproved[tokenId];
        balanceOf[tokenOwner]--;
        delete ownerOf[tokenId];
        emit Transfer(tokenOwner, address(0), tokenId);
    }

    /// @notice Approve an address to transfer a specific token
    /// @param to Address to approve
    /// @param tokenId Token ID
    function approve(address to, uint256 tokenId) external {
        address tokenOwner = ownerOf[tokenId];
        if (msg.sender != tokenOwner && !isApprovedForAll[tokenOwner][msg.sender]) {
            revert NotOwnerOrApproved();
        }
        getApproved[tokenId] = to;
        emit Approval(tokenOwner, to, tokenId);
    }

    /// @notice Set or revoke operator approval for all tokens
    /// @param operator Address to set approval for
    /// @param approved Whether to approve or revoke
    function setApprovalForAll(address operator, bool approved) external {
        isApprovedForAll[msg.sender][operator] = approved;
        emit ApprovalForAll(msg.sender, operator, approved);
    }

    /// @notice Transfer a token (caller must be owner or approved)
    /// @param from Current owner
    /// @param to Recipient
    /// @param tokenId Token ID
    function transferFrom(address from, address to, uint256 tokenId) public {
        if (!_exists(tokenId)) revert TokenDoesNotExist(tokenId);
        if (ownerOf[tokenId] != from) revert NotOwnerOrApproved();
        if (!_isApprovedOrOwner(msg.sender, tokenId)) revert NotOwnerOrApproved();
        if (to == address(0)) revert ZeroAddress();

        delete getApproved[tokenId];
        balanceOf[from]--;
        balanceOf[to]++;
        ownerOf[tokenId] = to;
        emit Transfer(from, to, tokenId);
    }

    /// @notice Safe transfer — checks if recipient can handle ERC721
    function safeTransferFrom(address from, address to, uint256 tokenId) external {
        safeTransferFrom(from, to, tokenId, "");
    }

    /// @notice Safe transfer with data — checks if recipient can handle ERC721
    function safeTransferFrom(address from, address to, uint256 tokenId, bytes memory data) public {
        transferFrom(from, to, tokenId);
        if (to.code.length > 0) {
            try IERC721Receiver(to).onERC721Received(msg.sender, from, tokenId, data) returns (bytes4 retval) {
                if (retval != IERC721Receiver.onERC721Received.selector) revert UnsafeRecipient();
            } catch {
                revert UnsafeRecipient();
            }
        }
    }

    /// @notice ERC165 interface support
    /// @param interfaceId Interface identifier
    function supportsInterface(bytes4 interfaceId) external pure returns (bool) {
        return interfaceId == 0x80ac58cd || // ERC721
               interfaceId == 0x01ffc9a7;   // ERC165
    }
}
