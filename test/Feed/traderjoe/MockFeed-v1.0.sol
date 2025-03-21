// SPDX-License-Identifier: GPL-3.0
pragma solidity ^0.8.29;

import {ERC20} from "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import {Math} from "@openzeppelin/contracts/utils/math/Math.sol";
import {Test} from "forge-std/Test.sol";

import {IPair_V1} from "../../../source/interface/feed/traderjoe/Pair-v1.0.sol";
import {Feed_V1} from "../../../source/contract/feed/traderjoe/Feed-v1.0.sol";
import {Feed_R1} from "../../../source/contract/feed/traderjoe/Feed-v1.0.sol";

struct MockPrice {
    uint256 bid;
    uint256 ask;
}

contract MockFeed_V1 is Feed_V1 {
    constructor(
        MockPrice[] memory prices
    ) Feed_V1(address(new MockPair(prices))) {}
}

contract MockFeed_R1 is Feed_R1 {
    constructor(
        MockPrice[] memory prices
    ) Feed_R1(address(new MockPair(prices))) {}
}

contract MockPair is IPair_V1 {
    ERC20 private immutable _t0 = new T0();
    ERC20 private immutable _t1 = new T1();
    MockPrice[] private _prices;

    constructor(MockPrice[] memory prices) {
        require(prices.length > 0, "MockPair: empty prices");
        for (uint256 i = 0; i < prices.length; i++) {
            _prices.push(prices[i]);
        }
    }

    function getReserves()
        external
        view
        override
        returns (uint112, uint112, uint32)
    {
        MockPrice memory p = _prices[
            Math.min(block.number, _prices.length) - 1
        ];
        return (uint112(p.bid), uint112(p.ask), uint32(block.timestamp));
    }

    function token0() external view override returns (address) {
        return address(_t0);
    }

    function token1() external view override returns (address) {
        return address(_t1);
    }
}

contract T0 is ERC20 {
    constructor() ERC20("Mock Token", "T0") {
        _mint(msg.sender, 1e36);
    }

    function decimals() public pure override returns (uint8) {
        return 18; // {6, 18, 36} et al.
    }
}

contract T1 is ERC20 {
    constructor() ERC20("Mock Token", "T1") {
        _mint(msg.sender, 1e36);
    }

    function decimals() public pure override returns (uint8) {
        return 18; // {6, 18, 36} et al.
    }
}
