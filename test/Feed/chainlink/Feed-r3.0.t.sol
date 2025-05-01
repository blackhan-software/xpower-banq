// SPDX-License-Identifier: GPL-3.0
pragma solidity ^0.8.28;

import {IFeed} from "../../../source/interface/Feed.sol";
import {MockFeed_R3} from "./MockFeed-v3.0.sol";
import {Test} from "forge-std/Test.sol";

contract FeedTest is Test {
    MockFeed_R3 private _feed = new MockFeed_R3(0.5e8, 8);

    function test_getQuotes_0e17() public view {
        (uint256 bid, uint256 ask) = _feed.getQuotes(0e17);
        assertEq(bid, 0.000000000000000000e18);
        assertEq(ask, 0.000000000000000000e18);
    }

    function test_getQuotes_1e17() public view {
        (uint256 bid, uint256 ask) = _feed.getQuotes(1e17);
        assertEq(bid, 0.200000000000000000e18);
        assertEq(ask, 0.200000000000000000e18);
    }

    function test_getQuotes_5e17() public view {
        (uint256 bid, uint256 ask) = _feed.getQuotes(5e17);
        assertEq(bid, 1.000000000000000000e18);
        assertEq(ask, 1.000000000000000000e18);
    }

    function test_getQuotes_9e17() public view {
        (uint256 bid, uint256 ask) = _feed.getQuotes(9e17);
        assertEq(bid, 1.800000000000000000e18);
        assertEq(ask, 1.800000000000000000e18);
    }

    function test_getQuotes_1e18() public view {
        (uint256 bid, uint256 ask) = _feed.getQuotes(1e18);
        assertEq(bid, 2.000000000000000000e18);
        assertEq(ask, 2.000000000000000000e18);
    }

    function test_getQuotes(uint256 amount) public view {
        amount = bound(amount, 0, type(uint256).max / 2);
        (uint256 bid, uint256 ask) = _feed.getQuotes(amount);
        assertEq(bid, amount * 2);
        assertEq(ask, amount * 2);
    }
}

contract FeedTest_NegativeQuote is Test {
    IFeed private _feed = new MockFeed_R3(-2e8, 8);

    function test_getQuotes_1e18() public {
        vm.expectRevert(
            abi.encodeWithSelector(IFeed.NegativeQuote.selector, -2e8)
        );
        _feed.getQuotes(1e18);
    }
}
