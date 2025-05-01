// SPDX-License-Identifier: GPL-3.0
pragma solidity ^0.8.28;

import {IAccessManaged} from "@openzeppelin/contracts/access/manager/AccessManager.sol";
import {IERC20} from "@openzeppelin/contracts/interfaces/IERC20.sol";
import {ERC20} from "@openzeppelin/contracts/token/ERC20/ERC20.sol";

import {PowLimitedLib} from "../../source/contract/modifier/PowLimited.sol";
import {IPowLimited} from "../../source/contract/modifier/PowLimited.sol";

import {IOracle} from "../../source/interface/Oracle.sol";
import {IFeed} from "../../source/interface/Feed.sol";
import {IAcma} from "../../source/interface/Acma.sol";
import {Acma} from "../../source/contract/Acma.sol";

import {Constant} from "../../source/library/Constant.sol";
import {Token} from "../../source/library/Token.sol";
import {Quote} from "../../source/struct/Quote.sol";

import {OracleInit} from "../../script/library/OracleInit.sol";
import {TJMockOracle, MockPrice} from "./MockOracle.tj.sol";
import {Test} from "forge-std/Test.sol";

contract OracleTest is Test {
    address immutable self = address(this);
    TJMockOracle internal immutable oracle;
    IAcma internal immutable acma;

    IERC20 immutable T0;
    IERC20 immutable T1;
    uint256 immutable U0;
    uint256 immutable U1;

    constructor() {
        MockPrice[] memory prices = new MockPrice[](1);
        prices[0] = MockPrice(100e18, 100e18);
        ///
        acma = new Acma(self);
        oracle = new TJMockOracle(prices, acma);
        acma.grantRole(acma.ACMA_RELATE_ROLE(), address(self), 0);
        OracleInit.enroll(oracle, acma);
        acma.revokeRole(acma.ACMA_RELATE_ROLE(), address(self));
        ///
        T0 = oracle.bidToken();
        T1 = oracle.askToken();
        U0 = Token.unitOf(T0);
        U1 = Token.unitOf(T1);
    }

    function refresh(uint256 hl) internal {
        vm.warp(Constant.HOUR * (hl));
        oracle.refresh(T0, T1);
        vm.warp(Constant.HOUR * (hl + 1));
        oracle.refresh(T0, T1);
    }

    bytes4 immutable AM_UNAUTHORIZED =
        IAccessManaged.AccessManagedUnauthorized.selector;
}

contract Oracle_Refresh is OracleTest {
    function setUp() public {
        acma.grantRole(acma.FEED_RETWAP_ROLE(), address(oracle), 0);
    }

    function test_refresh() public {
        refresh(1);
    }
}

contract Oracle_Refresh_PoW is OracleTest {
    using PowLimitedLib for bytes32;

    function setUp() public {
        acma.grantRole(acma.FEED_RETWAP_ROLE(), address(oracle), 0);
        acma.grantRole(acma.FEED_SET_TARGET_ROLE(), self, 0);
        oracle.setTarget(oracle.LEVEL_ID(), 1);
    }

    function test_refresh_pass(uint256 n) public {
        bytes memory args = abi.encodeWithSignature(
            "refresh(address,address)",
            T0,
            T1
        );
        bytes memory argn = abi.encodeWithSignature(
            "refresh(address,address)",
            T0,
            T1,
            n
        );
        bytes32 hashed = oracle.blockHash().key(tx.origin, argn);
        if (hashed.zeros() < 1) {
            return; // ignore
        }
        // 1st attempt: delayed? yes! (pow: skip)
        vm.warp(Constant.HOUR * 1);
        (bool ok1, bytes memory data1) = address(oracle).call(args);
        assertEq(data1.length, 0);
        assertTrue(ok1);
        // 2nd attempt: invoked? yes! (pow: pass)
        vm.warp(Constant.HOUR * 2);
        (IFeed feed, uint256 dt) = oracle.getFeed(T0, T1);
        assertTrue(feed != IFeed(address(0)));
        assertEq(dt, 0);
        (uint b, uint a) = feed.getQuotes(1e18);
        vm.expectEmit(true, true, true, true);
        emit Refresh(T0, T1, Quote(b, a, block.timestamp));
        (bool ok2, bytes memory data2) = address(oracle).call(argn);
        assertEq(data2.length, 0);
        assertTrue(ok2);
    }

    function test_refresh_fail(uint256 n) public {
        bytes memory args = abi.encodeWithSignature(
            "refresh(address,address)",
            T0,
            T1
        );
        bytes memory argn = abi.encodeWithSignature(
            "refresh(address,address)",
            T0,
            T1,
            n
        );
        bytes32 hashed = oracle.blockHash().key(tx.origin, argn);
        if (hashed.zeros() > 0) {
            return; // ignore
        }
        // 1st attempt: delayed? yes! (pow: skip)
        vm.warp(Constant.HOUR * 1);
        (bool ok1, bytes memory data1) = address(oracle).call(args);
        assertEq(data1.length, 0);
        assertTrue(ok1);
        // 2nd attempt: invoked? not! (pow: fail)
        vm.warp(Constant.HOUR * 2);
        vm.expectPartialRevert(IPowLimited.PowLimited.selector);
        (bool ok2, bytes memory data2) = address(oracle).call(argn);
        assertEq(data2.length, 8192);
        assertTrue(ok2);
    }

    event Refresh(IERC20 indexed source, IERC20 indexed t, Quote q);
}

contract Oracle_MissingFeed is OracleTest {
    function setUp() public {
        acma.grantRole(acma.FEED_RETWAP_ROLE(), address(oracle), 0);
    }

    function test_refresh() public {
        vm.warp(Constant.HOUR * 1);
        oracle.refresh(T0, MT);
        vm.expectRevert(
            abi.encodeWithSelector(IOracle.MissingFeed.selector, T0, MT)
        );
        vm.warp(Constant.HOUR * 2);
        oracle.refresh(T0, MT);
    }

    MockToken MT = new MockToken();
}

contract MockToken is ERC20 {
    constructor() ERC20("Mock Token", "MT") {}
}

contract Oracle_MissingQuote is OracleTest {
    function test_getQuote() public {
        vm.expectRevert(
            abi.encodeWithSelector(IOracle.MissingQuote.selector, T0, T1)
        );
        oracle.getQuote(U0, T0, T1);
    }

    function test_getQuotes() public {
        vm.expectRevert(
            abi.encodeWithSelector(IOracle.MissingQuote.selector, T0, T1)
        );
        oracle.getQuotes(U0, T0, T1);
    }
}

contract Oracle_DelayedRefresh is OracleTest {
    function setUp() public {
        acma.grantRole(acma.FEED_RETWAP_ROLE(), address(oracle), 0);
        refresh(1);
    }

    function test_refresh() public {
        bytes32 key = keccak256(
            abi.encodePacked(oracle.refresh.selector, T0, T1)
        );
        oracle.refresh(T0, T1);
        vm.expectRevert(abi.encodeWithSelector(Delayed.selector, key, 3600));
        oracle.refresh(T0, T1);
    }

    error Delayed(bytes32 key, uint256 duration);
}

contract Oracle_1HL is OracleTest {
    function setUp() public {
        acma.grantRole(acma.FEED_RETWAP_ROLE(), address(oracle), 0);
        refresh(1);
    }

    function test_getQuote() public view {
        uint256 q = oracle.getQuote(U0, T0, T1);
        assertEq(q, 1.000100010001000100e18);
    }

    function test_getQuotes() public view {
        (uint256 b, uint256 a) = oracle.getQuotes(U0, T0, T1);
        assertEq(b, 0.990099009900990099e18);
        assertEq(a, 1.010101010101010101e18);
    }
}

contract Oracle_6HL is OracleTest {
    function setUp() public {
        acma.grantRole(acma.FEED_RETWAP_ROLE(), address(oracle), 0);
        for (uint256 hl = 1; hl <= 6; hl++) {
            refresh(hl);
        }
    }

    function test_getQuote() public view {
        uint256 q = oracle.getQuote(U0, T0, T1);
        assertEq(q, 1.000100_010001_000097e18);
    }

    function test_getQuotes() public view {
        (uint256 b, uint256 a) = oracle.getQuotes(U0, T0, T1);
        assertEq(b, 0.990099_009900_990097e18);
        assertEq(a, 1.010101_010101_010097e18);
    }
}

contract Oracle_12H is OracleTest {
    function setUp() public {
        acma.grantRole(acma.FEED_RETWAP_ROLE(), address(oracle), 0);
        for (uint256 hl = 1; hl <= 12; hl++) {
            refresh(hl);
        }
    }

    function test_getQuote() public view {
        uint256 q = oracle.getQuote(U0, T0, T1);
        assertEq(q, 1.000100_010001_000097e18);
    }

    function test_getQuotes() public view {
        (uint256 b, uint256 a) = oracle.getQuotes(U0, T0, T1);
        assertEq(b, 0.990099_009900_990097e18);
        assertEq(a, 1.010101_010101_010097e18);
    }
}
