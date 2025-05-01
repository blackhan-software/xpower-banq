// SPDX-License-Identifier: GPL-3.0
pragma solidity ^0.8.28;

import {IParameterized} from "../../source/interface/governance/Parameterized.sol";
import {Constant} from "../../source/library/Constant.sol";
import {BaseTest} from "./Base.t.sol";

contract SupervisedTarget is BaseTest {
    constructor() BaseTest(VAULT_NIL, IR_MODEL) {}

    function setUp() public virtual {
        acma.grantRole(acma.SUPPLY_SET_TARGET_ROLE(), self, 0);
        vm.warp(block.timestamp + Constant.MONTH * 3);
    }

    bytes4 immutable TOO_LARGE = IParameterized.TooLarge.selector;
    bytes4 immutable TOO_SMALL = IParameterized.TooSmall.selector;
}

contract SupervisedTarget_Util is SupervisedTarget {
    function test_util(uint256 util) public {
        (uint tgt, ) = supply.getTarget(supply.UTIL_ID());
        util = bound(util, tgt / 2, Constant.ONE - 1);
        supply.setTarget(supply.UTIL_ID(), util);
    }

    function test_spread_event(uint256 util) public {
        (uint tgt1, ) = supply.getTarget(supply.UTIL_ID());
        util = bound(util, tgt1 / 2, Constant.ONE - 1);
        vm.expectEmit();
        emit IParameterized.Target(supply.UTIL_ID(), util, 0);
        supply.setTarget(supply.UTIL_ID(), util);
        (uint tgt2, ) = supply.getTarget(supply.UTIL_ID());
        assertEq(tgt2, util);
    }

    function test_util_gt_max() public {
        (uint id, uint max) = (supply.UTIL_ID(), Constant.ONE - 1);
        vm.expectRevert(abi.encodeWithSelector(TOO_LARGE, id, max + 1, max));
        supply.setTarget(id, max + 1);
    }

    function test_util_eq_min() public {
        (uint tgt, ) = supply.getTarget(supply.UTIL_ID());
        supply.setTarget(supply.UTIL_ID(), tgt / 2);
    }
}

contract SupervisedTarget_Rate is SupervisedTarget {
    function test_rate(uint256 rate) public {
        (uint tgt, ) = supply.getTarget(supply.RATE_ID());
        rate = bound(rate, tgt / 2, tgt * 2);
        supply.setTarget(supply.RATE_ID(), rate);
    }

    function test_rate_event(uint256 rate) public {
        (uint tgt1, ) = supply.getTarget(supply.RATE_ID());
        rate = bound(rate, tgt1 / 2, tgt1 * 2);
        vm.expectEmit();
        emit IParameterized.Target(supply.RATE_ID(), rate, 0);
        supply.setTarget(supply.RATE_ID(), rate);
        (uint tgt2, ) = supply.getTarget(supply.RATE_ID());
        assertEq(tgt2, rate);
    }

    function test_rate_eq_max() public {
        (uint tgt, ) = supply.getTarget(supply.RATE_ID());
        supply.setTarget(supply.RATE_ID(), tgt * 2);
    }

    function test_rate_eq_min() public {
        (uint tgt, ) = supply.getTarget(supply.RATE_ID());
        supply.setTarget(supply.RATE_ID(), tgt / 2);
    }
}

contract SupervisedTarget_Spread is SupervisedTarget {
    function test_spread(uint256 spread) public {
        spread = bound(spread, Constant.NIL, Constant.HLF);
        supply.setTarget(supply.SPREAD_ID(), spread);
    }

    function test_spread_event(uint256 spread) public {
        spread = bound(spread, Constant.NIL, Constant.HLF);
        vm.expectEmit();
        emit IParameterized.Target(supply.SPREAD_ID(), spread, 0);
        supply.setTarget(supply.SPREAD_ID(), spread);
        (uint tgt, ) = supply.getTarget(supply.SPREAD_ID());
        assertEq(tgt, spread);
    }

    function test_spread_gt_max() public {
        (uint id, uint max) = (supply.SPREAD_ID(), Constant.HLF);
        vm.expectRevert(abi.encodeWithSelector(TOO_LARGE, id, max + 1, max));
        supply.setTarget(id, max + 1);
    }

    function test_spread_eq_min() public {
        supply.setTarget(supply.SPREAD_ID(), Constant.NIL); // min=0
    }
}

contract SupervisedTarget_Unknown is SupervisedTarget {
    function test_unknown(uint256 value, uint256 dt) public {
        dt = bound(dt, 0, Constant.MONTH * 12);
        vm.expectRevert(abi.encodeWithSelector(UNKNOWN, 0x0));
        supply.setTarget(0x0, value, dt);
    }

    function test_unknown_cap(uint224 cap, uint256 dt) public {
        dt = bound(dt, 0, Constant.MONTH * 12);
        vm.expectRevert(abi.encodeWithSelector(UNKNOWN, supply.CAP_ID()));
        supply.setTarget(0x1, cap, dt);
    }

    bytes4 immutable UNKNOWN = IParameterized.Unknown.selector;
}
