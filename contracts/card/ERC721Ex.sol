pragma solidity ^0.7.0;

// SPDX-License-Identifier: SimPL-2.0

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "../interface/IERC721ReceiverEx.sol";
import "../manager/Member.sol";
import "../lib/Util.sol";

abstract contract ERC721Ex is ERC721, Member {
    using Address for address;

    uint256 public constant NFT_SIGN_BIT = 1 << 255;

    string public uriPrefix = "http://api.gamedao.com/";

    function safeBatchTransferFrom(
        address from,
        address to,
        uint256[] memory tokenIds
    ) external {
        safeBatchTransferFrom(from, to, tokenIds, "");
    }

    function safeBatchTransferFrom(
        address from,
        address to,
        uint256[] memory tokenIds,
        bytes memory data
    ) public {
        require(from != address(0), "from is zero address");
        require(to != address(0), "to is zero address");

        uint256 length = tokenIds.length;
        for (uint256 i = 0; i != length; ++i) {
            uint256 tokenId = tokenIds[i];
            safeTransferFrom(from, to, tokenId, data);
        }
        if (to.isContract()) {
            require(
                IERC721ReceiverEx(to).onERC721ExReceived(
                    msg.sender,
                    from,
                    tokenIds,
                    data
                ) == Util.ERC721_RECEIVER_EX_RETURN,
                "onERC721ExReceived() return invalid"
            );
        }
    }

    function batchTransferFrom(
        address from,
        address to,
        uint256[] memory tokenIds
    ) public {
        require(from != address(0), "from is zero address");
        require(to != address(0), "to is zero address");

        uint256 length = tokenIds.length;
        for (uint256 i = 0; i != length; ++i) {
            uint256 tokenId = tokenIds[i];
            safeTransferFrom(from, to, tokenId);
        }
    }

    function setUriPrefix(string memory prefix) external CheckPermit("Config") {
        uriPrefix = prefix;
    }

    // [startIndex, endIndex)
    function tokensOf(
        address owner,
        uint256 startIndex,
        uint256 endIndex
    ) external view returns (uint256[] memory) {
        require(owner != address(0), "owner is zero address");

        if (endIndex == 0) {
            endIndex = balanceOf(owner);
        }

        require(startIndex < endIndex, "invalid index");

        uint256[] memory result = new uint256[](endIndex - startIndex);
        for (uint256 i = startIndex; i != endIndex; ++i) {
            result[i] = tokenOfOwnerByIndex(owner, i);
        }

        return result;
    }
}
