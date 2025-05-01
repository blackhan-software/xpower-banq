// SPDX-License-Identifier: GPL-3.0
pragma solidity ^0.8.28;

import {IAccessManaged} from "@openzeppelin/contracts/access/manager/AccessManager.sol";
import {IERC20} from "@openzeppelin/contracts/interfaces/IERC20.sol";

import {IFeed} from "../../source/interface/Feed.sol";
import {Quote} from "../../source/library/TWAP.sol";
import {OracleTest} from "./Oracle.t.sol";

contract BaseTest is OracleTest {}

contract SupervisedRefresh is BaseTest {
    function setUp() public {
        acma.grantRole(acma.FEED_RETWAP_ROLE(), address(oracle), 0);
        oracle.refresh(T0, T1);
        vm.warp(3601 seconds);
    }

    function test_refreshed() public {
        assertEq(oracle.refreshed(T0, T1), false);
        oracle.refresh(T0, T1);
        assertEq(oracle.refreshed(T0, T1), true);
    }
}

contract SupervisedRefresh_Event is BaseTest {
    function setUp() public {
        acma.grantRole(acma.FEED_RETWAP_ROLE(), address(oracle), 0);
        oracle.refresh(T0, T1);
        vm.warp(3601 seconds);
    }

    function test_refresh() public {
        (IFeed feed, ) = oracle.getFeed(T0, T1);
        (uint b, uint a) = feed.getQuotes(U0);
        vm.expectEmit();
        emit Refresh(T0, T1, Quote(b, a, block.timestamp));
        oracle.refresh(T0, T1);
    }

    event Refresh(IERC20 indexed s, IERC20 indexed t, Quote q);
}

contract SupervisedRefresh_Unauthorized is BaseTest {
    function setUp() public {
        oracle.refresh(T0, T1);
        vm.warp(3601 seconds);
    }

    function test_refresh() public {
        vm.expectRevert(abi.encodeWithSelector(AM_UNAUTHORIZED, oracle));
        oracle.refresh(T0, T1);
    }
}
