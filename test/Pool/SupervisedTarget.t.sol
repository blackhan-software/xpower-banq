// SPDX-License-Identifier: GPL-3.0
pragma solidity ^0.8.28;

import {Math} from "@openzeppelin/contracts/utils/math/Math.sol";

import {IParameterized} from "../../source/interface/governance/Parameterized.sol";
import {Constant} from "../../source/library/Constant.sol";
import {PoolTest} from "./Pool.t.sol";

contract SupervisedTarget is PoolTest {
    constructor() PoolTest(TOKENS, VAULT_FEE, IR_MODEL, DELPHI) {}

    function setUp() public virtual {
        acma.grantRole(acma.POOL_SET_TARGET_ROLE(), self, 0);
        vm.warp(block.timestamp + Constant.MONTH * 12);
    }

    function limitAt(
        uint256 id,
        uint256 limit
    ) internal view returns (uint256 limit_at) {
        uint256 limit_now = pool.parameterOf(id);
        uint256 limit_max = Math.min(type(uint256).max, limit_now * 2 + 0);
        uint256 limit_min = Math.max(type(uint256).min, limit_now / 2 + 1);
        return bound(limit, limit_min, limit_max);
    }

    function weightAt(
        uint256 id,
        uint8 weight
    ) internal view returns (uint8 weight_at) {
        uint256 weight_now = pool.parameterOf(id);
        uint256 weight_max = Math.min(type(uint8).max, weight_now * 2 + 0);
        uint256 weight_min = Math.max(type(uint8).min, weight_now / 2 + 1);
        return uint8(bound(weight, weight_min, weight_max));
    }

    bytes4 immutable TOO_LARGE = IParameterized.TooLarge.selector;
    bytes4 immutable TOO_SMALL = IParameterized.TooSmall.selector;
}

contract SupervisedTarget_MaxLimit is SupervisedTarget {
    function test_supply(uint256 limit) public {
        uint256 id = pool.MAX_SUPPLY_ID(AVAX);
        pool.setTarget(id, limitAt(id, limit));
    }

    function test_borrow(uint256 limit) public {
        uint256 id = pool.MAX_BORROW_ID(AVAX);
        pool.setTarget(id, limitAt(id, limit));
    }

    function test_supply_event(uint256 limit) public {
        uint256 id = pool.MAX_SUPPLY_ID(AVAX);
        limit = limitAt(id, limit);
        vm.expectEmit();
        emit IParameterized.Target(id, limit, 0);
        pool.setTarget(id, limit);
        (uint256 tgt, ) = pool.getTarget(id);
        assertEq(tgt, limit);
    }

    function test_borrow_event(uint256 limit) public {
        uint256 id = pool.MAX_BORROW_ID(AVAX);
        limit = limitAt(id, limit);
        vm.expectEmit();
        emit IParameterized.Target(id, limit, 0);
        pool.setTarget(id, limit);
        (uint256 tgt, ) = pool.getTarget(id);
        assertEq(tgt, limit);
    }

    function test_supply_gt_max() public {
        uint256 id = pool.MAX_SUPPLY_ID(AVAX);
        uint256 max = pool.parameterOf(id) * 2;
        vm.expectRevert(abi.encodeWithSelector(TOO_LARGE, id, max + 1, max));
        pool.setTarget(id, max + 1);
    }

    function test_borrow_gt_max() public {
        uint256 id = pool.MAX_BORROW_ID(AVAX);
        uint256 max = pool.parameterOf(id) * 2;
        vm.expectRevert(abi.encodeWithSelector(TOO_LARGE, id, max + 1, max));
        pool.setTarget(id, max + 1);
    }

    function test_supply_lt_min() public {
        uint256 id = pool.MAX_SUPPLY_ID(AVAX);
        uint256 min = pool.parameterOf(id) / 2;
        vm.expectRevert(abi.encodeWithSelector(TOO_SMALL, id, min - 1, min));
        pool.setTarget(id, min - 1);
    }

    function test_borrow_lt_min() public {
        uint256 id = pool.MAX_BORROW_ID(AVAX);
        uint256 min = pool.parameterOf(id) / 2;
        vm.expectRevert(abi.encodeWithSelector(TOO_SMALL, id, min - 1, min));
        pool.setTarget(id, min - 1);
    }
}

contract SupervisedTarget_MinLimit is SupervisedTarget {
    function test_supply(uint256 limit) public {
        uint256 id = pool.MIN_SUPPLY_ID(AVAX);
        pool.setTarget(id, limitAt(id, limit));
    }

    function test_borrow(uint256 limit) public {
        uint256 id = pool.MIN_BORROW_ID(AVAX);
        pool.setTarget(id, limitAt(id, limit));
    }

    function test_supply_event(uint256 limit) public {
        uint256 id = pool.MIN_SUPPLY_ID(AVAX);
        limit = limitAt(id, limit);
        vm.expectEmit();
        emit IParameterized.Target(id, limit, 0);
        pool.setTarget(id, limit);
        (uint256 tgt, ) = pool.getTarget(id);
        assertEq(tgt, limit);
    }

    function test_borrow_event(uint256 limit) public {
        uint256 id = pool.MIN_BORROW_ID(AVAX);
        limit = limitAt(id, limit);
        vm.expectEmit();
        emit IParameterized.Target(id, limit, 0);
        pool.setTarget(id, limit);
        (uint256 tgt, ) = pool.getTarget(id);
        assertEq(tgt, limit);
    }

    function test_supply_gt_max() public {
        uint256 id = pool.MIN_SUPPLY_ID(AVAX);
        uint256 max = pool.parameterOf(id) * 2;
        vm.expectRevert(abi.encodeWithSelector(TOO_LARGE, id, max + 1, max));
        pool.setTarget(id, max + 1);
    }

    function test_borrow_gt_max() public {
        uint256 id = pool.MIN_BORROW_ID(AVAX);
        uint256 max = pool.parameterOf(id) * 2;
        vm.expectRevert(abi.encodeWithSelector(TOO_LARGE, id, max + 1, max));
        pool.setTarget(id, max + 1);
    }

    function test_supply_lt_min() public {
        uint256 id = pool.MIN_SUPPLY_ID(AVAX);
        uint256 min = pool.parameterOf(id) / 2;
        vm.expectRevert(abi.encodeWithSelector(TOO_SMALL, id, min - 1, min));
        pool.setTarget(id, min - 1);
    }

    function test_borrow_lt_min() public {
        uint256 id = pool.MIN_BORROW_ID(AVAX);
        uint256 min = pool.parameterOf(id) / 2;
        vm.expectRevert(abi.encodeWithSelector(TOO_SMALL, id, min - 1, min));
        pool.setTarget(id, min - 1);
    }
}

contract SupervisedTarget_PowLimit is SupervisedTarget {
    function test_supply(uint256 level) public {
        level = bound(level, 0, 64);
        pool.setTarget(pool.POW_SUPPLY_ID(AVAX), level);
    }

    function test_borrow(uint256 level) public {
        level = bound(level, 0, 64);
        pool.setTarget(pool.POW_BORROW_ID(AVAX), level);
    }

    function test_square(uint256 level, uint8 partial_exp) public {
        level = bound(level, 0, 64);
        pool.setTarget(pool.POW_SQUARE_ID(partial_exp), level);
    }

    function test_supply_event(uint256 level) public {
        level = bound(level, 0, 64);
        vm.expectEmit();
        emit IParameterized.Target(pool.POW_SUPPLY_ID(AVAX), level, 0);
        pool.setTarget(pool.POW_SUPPLY_ID(AVAX), level);
        (uint256 tgt, ) = pool.getTarget(pool.POW_SUPPLY_ID(AVAX));
        assertEq(tgt, level);
    }

    function test_borrow_event(uint256 level) public {
        level = bound(level, 0, 64);
        vm.expectEmit();
        emit IParameterized.Target(pool.POW_BORROW_ID(AVAX), level, 0);
        pool.setTarget(pool.POW_BORROW_ID(AVAX), level);
        (uint256 tgt, ) = pool.getTarget(pool.POW_BORROW_ID(AVAX));
        assertEq(tgt, level);
    }

    function test_square_event(uint256 level, uint8 partial_exp) public {
        level = bound(level, 0, 64);
        vm.expectEmit();
        emit IParameterized.Target(pool.POW_SQUARE_ID(partial_exp), level, 0);
        pool.setTarget(pool.POW_SQUARE_ID(partial_exp), level);
        (uint256 tgt, ) = pool.getTarget(pool.POW_SQUARE_ID(partial_exp));
        assertEq(tgt, level);
    }

    function test_supply_gt_max() public {
        (uint id, uint256 max) = (pool.POW_SUPPLY_ID(AVAX), 64);
        vm.expectRevert(abi.encodeWithSelector(TOO_LARGE, id, max + 1, max));
        pool.setTarget(id, max + 1);
    }

    function test_borrow_gt_max() public {
        (uint id, uint256 max) = (pool.POW_BORROW_ID(AVAX), 64);
        vm.expectRevert(abi.encodeWithSelector(TOO_LARGE, id, max + 1, max));
        pool.setTarget(id, max + 1);
    }

    function test_square_gt_max(uint8 partial_exp) public {
        (uint id, uint256 max) = (pool.POW_SQUARE_ID(partial_exp), 64);
        vm.expectRevert(abi.encodeWithSelector(TOO_LARGE, id, max + 1, max));
        pool.setTarget(id, max + 1);
    }

    function test_supply_eq_max() public {
        pool.setTarget(pool.POW_SUPPLY_ID(AVAX), 64);
    }

    function test_borrow_eq_max() public {
        pool.setTarget(pool.POW_BORROW_ID(AVAX), 64);
    }

    function test_square_eq_max(uint8 partial_exp) public {
        pool.setTarget(pool.POW_SQUARE_ID(partial_exp), 64);
    }

    function test_supply_eq_min() public {
        pool.setTarget(pool.POW_SUPPLY_ID(AVAX), 0);
    }

    function test_borrow_eq_min() public {
        pool.setTarget(pool.POW_BORROW_ID(AVAX), 0);
    }

    function test_square_eq_min(uint8 partial_exp) public {
        pool.setTarget(pool.POW_SQUARE_ID(partial_exp), 0);
    }
}

contract SupervisedTarget_Weight is SupervisedTarget {
    function test_supply(uint8 weight) public {
        uint256 id = pool.WEIGHT_SUPPLY_ID(AVAX);
        pool.setTarget(id, weightAt(id, weight));
    }

    function test_borrow(uint8 weight) public {
        uint256 id = pool.WEIGHT_BORROW_ID(AVAX);
        pool.setTarget(id, weightAt(id, weight));
    }

    function test_supply_event(uint8 weight) public {
        uint256 id = pool.WEIGHT_SUPPLY_ID(AVAX);
        weight = weightAt(id, weight);
        vm.expectEmit();
        emit IParameterized.Target(id, weight, 0);
        pool.setTarget(id, weight);
        (uint256 tgt, ) = pool.getTarget(id);
        assertEq(tgt, weight);
    }

    function test_borrow_event(uint8 weight) public {
        uint256 id = pool.WEIGHT_BORROW_ID(AVAX);
        weight = weightAt(id, weight);
        vm.expectEmit();
        emit IParameterized.Target(id, weight, 0);
        pool.setTarget(id, weight);
        (uint256 tgt, ) = pool.getTarget(id);
        assertEq(tgt, weight);
    }

    function test_supply_gt_max() public {
        (uint id, uint max) = (pool.WEIGHT_SUPPLY_ID(AVAX), type(uint8).max);
        vm.expectRevert(abi.encodeWithSelector(TOO_LARGE, id, max + 1, max));
        pool.setTarget(id, max + 1);
    }

    function test_borrow_gt_max() public {
        (uint id, uint max) = (pool.WEIGHT_BORROW_ID(AVAX), type(uint8).max);
        vm.expectRevert(abi.encodeWithSelector(TOO_LARGE, id, max + 1, max));
        pool.setTarget(id, max + 1);
    }

    function test_supply_lt_min() public {
        (uint id, uint min) = (pool.WEIGHT_SUPPLY_ID(AVAX), type(uint8).min);
        vm.expectRevert(abi.encodeWithSelector(TOO_SMALL, id, min, 85));
        pool.setTarget(id, min);
    }

    function test_borrow_lt_min() public {
        (uint id, uint min) = (pool.WEIGHT_BORROW_ID(AVAX), type(uint8).min);
        vm.expectRevert(abi.encodeWithSelector(TOO_SMALL, id, min, 127));
        pool.setTarget(id, min);
    }
}

contract SupervisedTarget_Unknown is SupervisedTarget {
    function test_unknown() public {
        vm.expectRevert(abi.encodeWithSelector(TGT_UNKNOWN, 0x0));
        pool.setTarget(0x0, 0);
    }

    bytes4 immutable TGT_UNKNOWN = IParameterized.Unknown.selector;
}
