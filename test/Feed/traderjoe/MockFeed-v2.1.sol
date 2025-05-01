// SPDX-License-Identifier: GPL-3.0
pragma solidity ^0.8.28;

import {ERC20} from "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import {Math} from "@openzeppelin/contracts/utils/math/Math.sol";
import {Test} from "forge-std/Test.sol";

import {IPair_V2} from "../../../source/interface/feed/traderjoe/Pair-v2.1.sol";
import {Feed_V2} from "../../../source/contract/feed/traderjoe/Feed-v2.1.sol";
import {Feed_R2} from "../../../source/contract/feed/traderjoe/Feed-v2.1.sol";

struct MockPrice {
    uint256 bid;
    uint256 ask;
}

contract MockFeed_V2 is Feed_V2 {
    constructor(
        MockPrice[] memory prices
    ) Feed_V2(address(new MockPair(prices))) {}
}

contract MockFeed_R2 is Feed_R2 {
    constructor(
        MockPrice[] memory prices
    ) Feed_R2(address(new MockPair(prices))) {}
}

contract MockPair is IPair_V2, Test {
    ERC20 private immutable _tx = new TX();
    ERC20 private immutable _ty = new TY();
    MockPrice[] private _prices;

    constructor(MockPrice[] memory prices) {
        require(prices.length > 0, "MockPair: empty prices");
        for (uint256 i = 0; i < prices.length; i++) {
            _prices.push(prices[i]);
        }
    }

    function setReserves(MockPrice memory price) external {
        _prices.push(price);
    }

    function getSwapOut(
        uint128 amount,
        bool swap_forY
    )
        external
        view
        override
        returns (uint128 in_left, uint128 amount_out, uint128 fee)
    {
        MockPrice memory p = _prices[
            Math.min(block.number, _prices.length) - 1
        ];
        if (p.ask <= type(uint128).max - amount && swap_forY) {
            uint256 bid = Math.mulDiv(amount, p.bid, p.ask + amount);
            return (0, uint128(bid), 0);
        }
        if (p.bid <= type(uint128).max - amount && !swap_forY) {
            uint256 bid = Math.mulDiv(amount, p.ask, p.bid + amount);
            return (0, uint128(bid), 0);
        }
        return (1, 0, 0); // fake left-over
    }

    function getSwapIn(
        uint128 amount,
        bool swap_forY
    )
        external
        view
        override
        returns (uint128 amount_in, uint128 out_left, uint128 fee)
    {
        MockPrice memory p = _prices[
            Math.min(block.number, _prices.length) - 1
        ];
        if (p.ask > amount && !swap_forY) {
            uint256 ask = Math.mulDiv(amount, p.bid, p.ask - amount);
            return (uint128(ask), 0, 0);
        }
        if (p.bid > amount && swap_forY) {
            uint256 ask = Math.mulDiv(amount, p.ask, p.bid - amount);
            return (uint128(ask), 0, 0);
        }
        return (0, 1, 0); // fake left-over
    }

    function getTokenX() external view override returns (address) {
        return address(_tx);
    }

    function getTokenY() external view override returns (address) {
        return address(_ty);
    }
}

contract TX is ERC20 {
    constructor() ERC20("Mock Token", "TX") {
        _mint(msg.sender, 1e36);
    }

    function decimals() public pure override returns (uint8) {
        return 18; // {6, 18, 36} et al.
    }
}

contract TY is ERC20 {
    constructor() ERC20("Mock Token", "TY") {
        _mint(msg.sender, 1e36);
    }

    function decimals() public pure override returns (uint8) {
        return 18; // {6, 18, 36} et al.
    }
}
