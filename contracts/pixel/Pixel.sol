pragma solidity ^0.7.0;
pragma experimental ABIEncoderV2;
// SPDX-License-Identifier: SimPL-2.0

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/utils/Counters.sol";
import "../card/ERC721Ex.sol";
import "@openzeppelin/contracts/math/SafeMath.sol";

contract Pixel is ERC721Ex {
    using SafeMath for uint256;

    using Counters for Counters.Counter;
    Counters.Counter private _tokenIds;
    mapping(address => bool) minters;

    bool public isRunning = true;

    struct PixelInfo {
        uint256 id;
        string name;
        string url;
        uint256 mintTime;
    }

    mapping(uint256 => PixelInfo) internal pixelInfos;

    constructor(string memory _name, string memory _symbol)
        ERC721(_name, _symbol)
    {}

    function setMinter(address minter, bool enable)
        external
        CheckPermit("Config")
    {
        minters[minter] = enable;
    }

    function setRunning(bool _isRunning) external CheckPermit("Config") {
        isRunning = _isRunning;
    }

    function mint(
        address owner,
        string memory name,
        string memory tokenURI
    ) external {
        require(isRunning, "It's not running");
        require(minters[msg.sender], "minter only");

        _tokenIds.increment();
        uint256 pixelId = _tokenIds.current();
        _mint(owner, pixelId);
        PixelInfo memory info = PixelInfo({
            id: pixelId,
            name: name,
            url: tokenURI,
            mintTime: block.timestamp
        });
        pixelInfos[pixelId] = info;
    }

    function tokenURI(uint256 _tokenId)
        public
        view
        override
        returns (string memory)
    {
        return pixelInfos[_tokenId].url;
    }

    function getTokenInfo(uint256 _tokenId)
        external
        view
        returns (PixelInfo memory)
    {
        return pixelInfos[_tokenId];
    }

    function getPixelInfos(uint256[] memory pixelIds)
        external
        view
        returns (PixelInfo[] memory)
    {
        PixelInfo[] memory result = new PixelInfo[](pixelIds.length);
        for (uint256 i = 0; i < pixelIds.length; i++) {
            result[i] = pixelInfos[pixelIds[i]];
        }
        return result;
    }

    function setTokenURIs(uint256[] memory pixelIds, string[] memory tokenURIs)
        external
        CheckPermit("Config")
    {
        require(
            pixelIds.length == tokenURIs.length,
            "arrays lengths are not the same"
        );
        for (uint256 i = 0; i < pixelIds.length; i++) {
            pixelInfos[pixelIds[i]].url = tokenURIs[i];
        }
    }
}
