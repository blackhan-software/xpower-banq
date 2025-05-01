// SPDX-License-Identifier: GPL-3.0
pragma solidity ^0.8.28;

import {IERC20} from "@openzeppelin/contracts/interfaces/IERC20.sol";

import {MockFeed_V1, MockPrice} from "../Feed/traderjoe/MockFeed-v1.0.sol";
import {IOracle} from "../../source/interface/Oracle.sol";
import {IFeed} from "../../source/interface/Feed.sol";
import {OracleTest} from "./Oracle.t.sol";
import {Token} from "../Pool/Base.t.sol";

contract BaseTest is OracleTest {
    IFeed immutable _zero = IFeed(address(0));
    IFeed immutable _feed;

    constructor() OracleTest() {
        MockPrice[] memory prices = new MockPrice[](1);
        prices[0] = MockPrice(100e18, 100e18);
        _feed = new MockFeed_V1(prices);
    }

    event Enlist(IERC20 indexed s, IERC20 indexed t, IFeed f, uint256 dt);
    event Pending(bytes32 indexed k, uint256 ts);
}

contract SupervisedEnlist is BaseTest {
    function setUp() public {
        acma.grantRole(acma.FEED_ENLIST_ROLE(), self, 0);
        oracle.enlist(T0, T1, _feed, 0); // pending
        vm.warp(block.timestamp + 14 days);
        oracle.enlist(T0, T1, _feed, 0); // invoked
        acma.revokeRole(acma.FEED_ENLIST_ROLE(), self);
    }

    function test_enlisted() public view {
        assertEq(oracle.enlisted(T0, T1), true);
        (IFeed feed, uint256 dt) = oracle.getFeed(T0, T1);
        assertTrue(feed == _feed);
        assertEq(dt, 0);
    }
}

contract SupervisedEnlist_Event is BaseTest {
    function setUp() public {
        acma.grantRole(acma.FEED_ENLIST_ROLE(), self, 0);
    }

    function test_enlist_pending() public {
        bytes32 key = keccak256(
            abi.encodePacked(oracle.enlist.selector, T0, T1)
        );
        vm.expectEmit();
        emit Pending(key, block.timestamp + 14 days);
        oracle.enlist(T0, T1, _feed, 0);
    }

    function test_enlist_invoked() public {
        oracle.enlist(T0, T1, _feed, 0);
        vm.warp(block.timestamp + 14 days);
        vm.expectEmit();
        emit Enlist(T0, T1, _feed, 0);
        oracle.enlist(T0, T1, _feed, 0);
    }
}

contract SupervisedEnlist_Duration is BaseTest {
    function setUp() public {
        acma.grantRole(acma.FEED_ENLIST_ROLE(), self, 0);
        oracle.enlist(T0, T1, _feed, 14 days); // pending
        vm.warp(block.timestamp + 14 days);
        oracle.enlist(T0, T1, _feed, 99 days); // invoked
        acma.revokeRole(acma.FEED_ENLIST_ROLE(), self);
    }

    function test_enlisted() public view {
        assertEq(oracle.enlisted(T0, T1), true);
        (IFeed feed, uint256 dt) = oracle.getFeed(T0, T1);
        assertTrue(feed == _feed);
        assertEq(dt, 99 days);
    }

    function test_enlist_early() public {
        acma.grantRole(acma.FEED_ENLIST_ROLE(), self, 0);
        oracle.enlist(T0, T1, _zero, 0); // pending
        vm.expectRevert(
            abi.encodeWithSelector(TOO_EARLY, T0, T1, _zero, 85 days)
        );
        vm.warp(block.timestamp + 14 days);
        oracle.enlist(T0, T1, _zero, 0); // invoked
        acma.revokeRole(acma.FEED_ENLIST_ROLE(), self);
    }

    function test_enlist_retro() public {
        acma.grantRole(acma.FEED_ENLIST_ROLE(), self, 0);
        oracle.enlist(T0, T1, _feed, 0); // pending
        vm.expectRevert(
            abi.encodeWithSelector(TOO_RETRO, T0, T1, _feed, 85 days)
        );
        vm.warp(block.timestamp + 14 days);
        oracle.enlist(T0, T1, _feed, 0); // invoked
        acma.revokeRole(acma.FEED_ENLIST_ROLE(), self);
    }

    function test_enlist_after() public {
        acma.grantRole(acma.FEED_ENLIST_ROLE(), self, 0);
        oracle.enlist(T0, T1, _zero, 0); // pending
        vm.warp(block.timestamp + 99 days);
        oracle.enlist(T0, T1, _zero, 0); // invoked
        acma.revokeRole(acma.FEED_ENLIST_ROLE(), self);
    }

    bytes4 immutable TOO_EARLY = IOracle.TooEarlyFeed.selector;
    bytes4 immutable TOO_RETRO = IOracle.TooRetroFeed.selector;
}

contract SupervisedEnlist_ZeroFeed is BaseTest {
    function setUp() public {
        acma.grantRole(acma.FEED_ENLIST_ROLE(), self, 0);
        oracle.enlist(T0, T1, _zero, 0); // pending
        vm.warp(block.timestamp + 14 days);
        oracle.enlist(T0, T1, _zero, 0); // invoked
    }

    function test_enlisted() public view {
        assertEq(oracle.enlisted(T0, T1), false);
    }
}

contract SupervisedEnlist_NewPair is BaseTest {
    function setUp() public {
        acma.grantRole(acma.FEED_ENLIST_ROLE(), self, 0);
    }

    function test_enlist_now() public {
        bytes32 key = keccak256(
            abi.encodePacked(oracle.enlist.selector, T0, T3)
        );
        vm.expectEmit();
        emit Pending(key, block.timestamp);
        oracle.enlist(T0, T3, _feed, 0); // pending: w/o delay!
        vm.warp(block.timestamp + 0 seconds);
        oracle.enlist(T0, T3, _feed, 0); // invoked: w/o delay!
        assertEq(oracle.enlisted(T0, T3), true);
    }

    function test_enlist_later() public {
        bytes32 key = keccak256(
            abi.encodePacked(oracle.enlist.selector, T0, T3)
        );
        vm.expectEmit();
        emit Pending(key, block.timestamp);
        oracle.enlist(T0, T3, _feed, 0); // pending: w/o delay!
        vm.warp(block.timestamp + 999 days);
        oracle.enlist(T0, T3, _feed, 0); // invoked: w/o delay!
        assertEq(oracle.enlisted(T0, T3), true);
    }

    Token T3 = new Token(1e18, "T3", 18);
}

contract SupervisedEnlist_InvalidPair is BaseTest {
    function setUp() public {
        acma.grantRole(acma.FEED_ENLIST_ROLE(), self, 0);
    }

    function test_enlist() public {
        bytes32 key = keccak256(
            abi.encodePacked(oracle.enlist.selector, T0, T0)
        );
        vm.expectEmit();
        emit Pending(key, block.timestamp);
        oracle.enlist(T0, T0, _feed, 0); // pending: w/o delay!
        vm.expectRevert(abi.encodeWithSelector(INVALID_PAIR, T0, T0));
        oracle.enlist(T0, T0, _feed, 0); // invoked: w/o delay!
        assertEq(oracle.enlisted(T0, T0), false);
    }

    bytes4 immutable INVALID_PAIR = IOracle.InvalidPair.selector;
}

contract SupervisedEnlist_Unauthorized is BaseTest {
    function setUp() public {
        acma.grantRole(acma.FEED_ENLIST_ROLE(), self, 0);
        oracle.enlist(T0, T1, _zero, 0); // pending
        vm.warp(block.timestamp + 14 days);
        oracle.enlist(T0, T1, _zero, 0); // invoked
        acma.revokeRole(acma.FEED_ENLIST_ROLE(), self);
    }

    function test_enlist() public {
        vm.expectRevert(abi.encodeWithSelector(AM_UNAUTHORIZED, self));
        oracle.enlist(T0, T1, _feed, 0);
        assertEq(oracle.enlisted(T0, T1), false);
    }
}
