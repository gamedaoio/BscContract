pragma solidity ^0.7.0;
pragma experimental ABIEncoderV2;
// SPDX-License-Identifier: SimPL-2.0

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "../manager/Member.sol";
import "@openzeppelin/contracts/math/SafeMath.sol";
import "./Pixel.sol";

contract PixelDraw is Member {
    using SafeMath for uint256;

    address public pixel;
    address public token;
    uint256 public price;

    bool public isRunning = true;

    constructor(
        address _pixel,
        address _token,
        uint256 _price
    ) {
        require(_pixel != address(0), "_pixel address cannot be 0");
        require(_token != address(0), "_token address cannot be 0");
        pixel = _pixel;
        token = _token;
        price = _price;
    }

    function setToken(address _token) external CheckPermit("Config") {
        require(_token != address(0), "_token address cannot be 0");
        token = _token;
    }

    function setPirce(uint256 _price) external CheckPermit("Config") {
        price = _price;
    }

    function setRunning(bool _isRunning) external CheckPermit("Config") {
        isRunning = _isRunning;
    }

    function draw(string memory name, string memory tokenURI)
        external
        validUser(msg.sender)
    {
        require(isRunning, "It's not running");

        require(
            IERC20(token).transferFrom(
                msg.sender,
                manager.members("drawer"),
                price
            ),
            "transfer invalid"
        );
        Pixel(pixel).mint(msg.sender, name, tokenURI);
    }
}
