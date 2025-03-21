// SPDX-License-Identifier: GPL-3.0
pragma solidity ^0.8.29;

import {IParameterized} from "../../source/interface/governance/Parameterized.sol";
import {Constant} from "../../source/library/Constant.sol";
import {OracleTest} from "./Oracle.t.sol";

contract SupervisedTarget is OracleTest {
    function setUp() public {
        acma.grantRole(acma.FEED_SET_TARGET_ROLE(), self, 0);
        vm.warp(block.timestamp + Constant.MONTH * 12);
    }

    bytes4 immutable TOO_LARGE = IParameterized.TooLarge.selector;
    bytes4 immutable TOO_SMALL = IParameterized.TooSmall.selector;
}

contract SupervisedTarget_Decay is SupervisedTarget {
    function test_decay(uint256 decay) public {
        decay = bound(decay, Constant.HLF, Constant.ONE);
        oracle.setTarget(oracle.DECAY_ID(), decay);
    }

    function test_decay_event(uint256 decay) public {
        decay = bound(decay, Constant.HLF, Constant.ONE);
        vm.expectEmit();
        emit IParameterized.Target(oracle.DECAY_ID(), decay, 0);
        oracle.setTarget(oracle.DECAY_ID(), decay);
        (uint256 tgt, ) = oracle.getTarget(oracle.DECAY_ID());
        assertEq(tgt, decay);
    }

    function test_decay_gt_max() public {
        (uint id, uint256 max) = (oracle.DECAY_ID(), Constant.ONE);
        vm.expectRevert(abi.encodeWithSelector(TOO_LARGE, id, max + 1, max));
        oracle.setTarget(id, max + 1);
    }

    function test_decay_lt_min() public {
        (uint id, uint256 min) = (oracle.DECAY_ID(), Constant.HLF);
        vm.expectRevert(abi.encodeWithSelector(TOO_SMALL, id, min - 1, min));
        oracle.setTarget(id, min - 1);
    }
}

contract SupervisedTarget_Delay is SupervisedTarget {
    function test_delayed(uint256 delay) public {
        (uint256 tgt, ) = oracle.getTarget(oracle.DELAY_ID());
        delay = bound(delay, tgt / 2, tgt * 2);
        oracle.setTarget(oracle.DELAY_ID(), delay);
    }

    function test_delay_event(uint256 delay) public {
        (uint256 tgt1, ) = oracle.getTarget(oracle.DELAY_ID());
        delay = bound(delay, tgt1 / 2, tgt1 * 2);
        vm.expectEmit();
        emit IParameterized.Target(oracle.DELAY_ID(), delay, 0);
        oracle.setTarget(oracle.DELAY_ID(), delay);
        (uint256 tgt2, ) = oracle.getTarget(oracle.DELAY_ID());
        assertEq(tgt2, delay);
    }

    function test_delay_eq_max() public {
        (uint256 tgt, ) = oracle.getTarget(oracle.DELAY_ID());
        oracle.setTarget(oracle.DELAY_ID(), tgt * 2);
    }

    function test_delay_eq_min() public {
        (uint256 tgt, ) = oracle.getTarget(oracle.DELAY_ID());
        oracle.setTarget(oracle.DELAY_ID(), tgt / 2);
    }
}

contract SupervisedTarget_Level is SupervisedTarget {
    function test_level(uint256 level) public {
        level = bound(level, 0, 64);
        oracle.setTarget(oracle.LEVEL_ID(), level);
    }

    function test_level_event(uint256 level) public {
        level = bound(level, 0, 64);
        vm.expectEmit();
        emit IParameterized.Target(oracle.LEVEL_ID(), level, 0);
        oracle.setTarget(oracle.LEVEL_ID(), level);
        (uint256 tgt, ) = oracle.getTarget(oracle.LEVEL_ID());
        assertEq(tgt, level);
    }

    function test_level_eq_max() public {
        oracle.setTarget(oracle.LEVEL_ID(), 64);
    }

    function test_level_eq_min() public {
        oracle.setTarget(oracle.LEVEL_ID(), 0);
    }
}

contract SupervisedTarget_Limit is SupervisedTarget {
    function test_limit(uint256 limit) public {
        (uint256 tgt, ) = oracle.getTarget(oracle.LIMIT_ID());
        limit = bound(limit, tgt / 2, tgt * 2);
        oracle.setTarget(oracle.LIMIT_ID(), limit);
    }

    function test_limit_event(uint256 limit) public {
        (uint256 tgt1, ) = oracle.getTarget(oracle.LIMIT_ID());
        limit = bound(limit, tgt1 / 2, tgt1 * 2);
        vm.expectEmit();
        emit IParameterized.Target(oracle.LIMIT_ID(), limit, 0);
        oracle.setTarget(oracle.LIMIT_ID(), limit);
        (uint256 tgt2, ) = oracle.getTarget(oracle.LIMIT_ID());
        assertEq(tgt2, limit);
    }

    function test_limit_eq_max() public {
        (uint256 tgt, ) = oracle.getTarget(oracle.LIMIT_ID());
        oracle.setTarget(oracle.LIMIT_ID(), tgt * 2);
    }

    function test_limit_eq_min() public {
        (uint256 tgt, ) = oracle.getTarget(oracle.LIMIT_ID());
        oracle.setTarget(oracle.LIMIT_ID(), tgt / 2);
    }
}

contract SupervisedTarget_Unknown is SupervisedTarget {
    function test_unknown() public {
        vm.expectRevert(abi.encodeWithSelector(TGT_UNKNOWN, 0x0));
        oracle.setTarget(0x0, 0);
    }

    bytes4 immutable TGT_UNKNOWN = IParameterized.Unknown.selector;
}
