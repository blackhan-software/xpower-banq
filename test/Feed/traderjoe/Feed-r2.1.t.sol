// SPDX-License-Identifier: GPL-3.0
pragma solidity ^0.8.28;

import {IFeed} from "../../../source/interface/Feed.sol";
import {MockFeed_R2, MockPrice} from "./MockFeed-v2.1.sol";
import {Test} from "forge-std/Test.sol";

contract BaseTest is Test {
    MockFeed_R2 internal immutable _feed;
    MockPrice[] internal _prices;

    constructor() {
        _prices.push(MockPrice(1e18, 2e18));
        _feed = new MockFeed_R2(_prices);
    }
}

contract FeedTest is BaseTest {
    function test_getQuotes_0e17() public view {
        (uint256 bid, uint256 ask) = _feed.getQuotes(0e17);
        assertEq(bid, 0.000000000000000000e18);
        assertEq(ask, 0.000000000000000000e18);
    }

    function test_getQuotes_1e17() public view {
        (uint256 bid, uint256 ask) = _feed.getQuotes(1e17);
        assertEq(bid, 0.181818181818181818e18);
        assertEq(ask, 0.222222222222222222e18);
    }

    function test_getQuotes_5e17() public view {
        (uint256 bid, uint256 ask) = _feed.getQuotes(5e17);
        assertEq(bid, 0.666666666666666666e18);
        assertEq(ask, 2.000000000000000000e18);
    }

    function test_getQuotes_9e17() public view {
        (uint256 bid, uint256 ask) = _feed.getQuotes(9e17);
        assertEq(bid, 0.947368421052631578e18);
        assertEq(ask, 1.800000000000000000e19);
    }
}

contract FeedTest_ArithmeticOverflow is BaseTest {
    function test_getQuotes() public {
        uint256 amount = type(uint128).max + uint256(1);
        vm.expectRevert(
            abi.encodeWithSelector(IFeed.ArithmeticOverflow.selector, amount)
        );
        _feed.getQuotes(amount);
    }
}

contract FeedTest_InsufficientLiquidity is BaseTest {
    function test_getQuotes_max() public {
        uint256 amount = type(uint128).max - 1e18 + 1;
        vm.expectRevert(
            abi.encodeWithSelector(IFeed.InsufficientLiquidity.selector, amount)
        );
        _feed.getQuotes(amount);
    }

    function test_getQuotes_2e18() public {
        vm.expectRevert(
            abi.encodeWithSelector(IFeed.InsufficientLiquidity.selector, 2e18)
        );
        _feed.getQuotes(2e18);
    }
}
