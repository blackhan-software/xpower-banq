// SPDX-License-Identifier: GPL-3.0
pragma solidity ^0.8.28;

import {IAccessManaged} from "@openzeppelin/contracts/access/manager/AccessManager.sol";
import {Parameterized} from "../../source/contract/governance/Parameterized.sol";
import {Limited, ILimited} from "../../source/contract/modifier/Limited.sol";
import {Constant} from "../../source/library/Constant.sol";
import {Selector} from "../../source/library/Selector.sol";
import {Acma} from "../../source/contract/Acma.sol";
import {Test} from "forge-std/Test.sol";

contract TestParameterized is Test, Parameterized {
    Acma immutable acma = new Acma(address(this));
    address immutable self = address(this);

    constructor() Parameterized(acma) {}

    function setUp() public virtual {
        acma.grantRole(acma.ACMA_RELATE_ROLE(), self, 0);
        acma.relate(self, Selector.SET_TARGET, acma.POOL_SET_TARGET_ROLE());
        acma.revokeRole(acma.ACMA_RELATE_ROLE(), self);
        acma.grantRole(acma.POOL_SET_TARGET_ROLE(), self, 0);
    }

    uint256 constant ID1 = 1;
    uint256 constant ID2 = 2;
}

contract ParameterOf is TestParameterized {
    function test() public view {
        assertEq(this.parameterOf(ID1), 0);
    }

    function test_1_const() public {
        assertEq(block.timestamp, 1);
        ///
        assertEq(this.parameterOf(ID1), 0.000e18);
        this.setTarget(ID1, 1.000e18);
        assertEq(this.parameterOf(ID1), 1.000e18);
        ///
        vm.warp(12 * Constant.MONTH + 1);
        ///
        assertEq(this.parameterOf(ID1), 1.000e18);
        this.setTarget(ID1, 1.000e18);
        assertEq(this.parameterOf(ID1), 1.000e18);
        ///
        vm.warp(24 * Constant.MONTH + 1);
        ///
        assertEq(this.parameterOf(ID1), 1.000e18);
        this.setTarget(ID1, 1.000e18);
        assertEq(this.parameterOf(ID1), 1.000e18);
        ///
        vm.warp(48 * Constant.MONTH + 1);
        ///
        assertEq(this.parameterOf(ID1), 1.000e18);
        this.setTarget(ID1, 1.000e18);
        assertEq(this.parameterOf(ID1), 1.000e18);
        ///
        vm.warp(96 * Constant.MONTH + 1);
        ///
        assertEq(this.parameterOf(ID1), 1.000e18);
        this.setTarget(ID1, 1.000e18);
        assertEq(this.parameterOf(ID1), 1.000e18);
    }

    function test_0_to_1_const() public {
        assertEq(block.timestamp, 1);
        ///
        assertEq(this.parameterOf(ID1), 0.000e18);
        this.setTarget(ID1, 0.000e18);
        assertEq(this.parameterOf(ID1), 0.000e18);
        ///
        vm.warp(12 * Constant.MONTH + 1);
        ///
        assertEq(this.parameterOf(ID1), 0.000e18);
        this.setTarget(ID1, 1.000e18);
        assertEq(this.parameterOf(ID1), 0.000e18);
        ///
        vm.warp(24 * Constant.MONTH + 1);
        ///
        assertEq(this.parameterOf(ID1), 0.500e18);
        this.setTarget(ID1, 1.000e18); // idempotent
        assertEq(this.parameterOf(ID1), 0.500e18);
        ///
        vm.warp(48 * Constant.MONTH + 1);
        ///
        assertEq(this.parameterOf(ID1), 0.750e18);
        this.setTarget(ID1, 1.000e18); // idempotent
        assertEq(this.parameterOf(ID1), 0.750e18);
        ///
        vm.warp(96 * Constant.MONTH + 1);
        ///
        assertEq(this.parameterOf(ID1), 0.875e18);
        this.setTarget(ID1, 1.000e18); // idempotent
        assertEq(this.parameterOf(ID1), 0.875e18);
    }

    function test_mul_by_2() public {
        assertEq(block.timestamp, 1);
        ///
        assertEq(this.parameterOf(ID1), 0.000e18);
        this.setTarget(ID1, 0.000e18);
        assertEq(this.parameterOf(ID1), 0.000e18);
        ///
        vm.warp(12 * Constant.MONTH + 1);
        ///
        assertEq(this.parameterOf(ID1), 0.000e18);
        this.setTarget(ID1, 1.000e18);
        assertEq(this.parameterOf(ID1), 0.000e18);
        ///
        vm.warp(24 * Constant.MONTH + 1);
        ///
        assertEq(this.parameterOf(ID1), 0.500e18);
        this.setTarget(ID1, 2.000e18);
        assertEq(this.parameterOf(ID1), 0.500e18);
        ///
        vm.warp(48 * Constant.MONTH + 1);
        ///
        assertEq(this.parameterOf(ID1), 1.250e18);
        this.setTarget(ID1, 4.000e18);
        assertEq(this.parameterOf(ID1), 1.250e18);
        ///
        vm.warp(96 * Constant.MONTH + 1);
        ///
        assertEq(this.parameterOf(ID1), 2.625e18);
        this.setTarget(ID1, 8.000e18);
        assertEq(this.parameterOf(ID1), 2.625e18);
    }

    function test_div_by_2() public {
        assertEq(block.timestamp, 1);
        ///
        assertEq(this.parameterOf(ID1), 0.000e18);
        this.setTarget(ID1, 1.000e18);
        assertEq(this.parameterOf(ID1), 1.000e18);
        ///
        vm.warp(12 * Constant.MONTH + 1);
        ///
        assertEq(this.parameterOf(ID1), 1.000e18);
        this.setTarget(ID1, 0.500e18);
        assertEq(this.parameterOf(ID1), 1.000e18);
        ///
        vm.warp(24 * Constant.MONTH + 1);
        ///
        assertEq(this.parameterOf(ID1), 0.750e18);
        this.setTarget(ID1, 0.250e18);
        assertEq(this.parameterOf(ID1), 0.750e18);
        ///
        vm.warp(48 * Constant.MONTH + 1);
        ///
        assertEq(this.parameterOf(ID1), 0.500e18);
        this.setTarget(ID1, 0.125e18);
        assertEq(this.parameterOf(ID1), 0.500e18);
        ///
        vm.warp(96 * Constant.MONTH + 1);
        ///
        assertEq(this.parameterOf(ID1), 3.125e17);
        this.setTarget(ID1, 0.625e17);
        assertEq(this.parameterOf(ID1), 3.125e17);
    }
}

contract GetTarget is TestParameterized {
    function test() public view {
        (uint256 tgt, uint256 tmp) = this.getTarget(ID1);
        assertEq(tgt, 0);
        assertEq(tmp, 0);
    }
}

contract SetTarget is TestParameterized {
    function test() public {
        (uint256 tgt1, uint256 tmp1) = this.getTarget(ID1);
        assertEq(tgt1, 0);
        assertEq(tmp1, 0);
        this.setTarget(ID1, 1);
        (uint256 tgt2, uint256 tmp2) = this.getTarget(ID1);
        assertEq(tgt2, 1);
        assertEq(tmp2, 0);
    }
}

contract SetTarget_Event is TestParameterized {
    function test() public {
        vm.expectEmit();
        emit Target(ID1, 1, 0);
        this.setTarget(ID1, 1);
    }
}

contract SetTarget_Duration is TestParameterized {
    function test_early() public {
        this.setTarget(ID1, 3, Constant.MONTH * 12);
        vm.warp(block.timestamp + Constant.MONTH);
        vm.expectRevert(
            abi.encodeWithSelector(TOO_EARLY, ID1, 6, Constant.MONTH * 11)
        );
        this.setTarget(ID1, 6);
        (uint256 tgt, uint256 dt) = this.getTarget(ID1);
        assertEq(dt, Constant.MONTH * 11);
        assertEq(tgt, 3);
    }

    function test_retro() public {
        this.setTarget(ID1, 3, Constant.MONTH * 12);
        vm.warp(block.timestamp + Constant.MONTH);
        vm.expectRevert(
            abi.encodeWithSelector(TOO_RETRO, ID1, 3, Constant.MONTH * 11)
        );
        this.setTarget(ID1, 3, Constant.MONTH * 5);
        (uint256 tgt, uint256 dt) = this.getTarget(ID1);
        assertEq(dt, Constant.MONTH * 11);
        assertEq(tgt, 3);
    }

    function test_later_99M() public {
        this.setTarget(ID1, 3, Constant.MONTH * 12);
        vm.warp(block.timestamp + Constant.MONTH);
        this.setTarget(ID1, 3, Constant.MONTH * 99);
        (uint256 tgt, uint256 dt) = this.getTarget(ID1);
        assertEq(dt, Constant.MONTH * 99);
        assertEq(tgt, 3);
    }

    function test_later_max() public {
        this.setTarget(ID1, 3, Constant.MONTH * 12);
        vm.warp(block.timestamp + Constant.MONTH);
        this.setTarget(ID1, 3, type(uint256).max);
        (uint256 tgt, uint256 dt) = this.getTarget(ID1);
        assertEq(dt, type(uint256).max - block.timestamp);
        assertEq(tgt, 3);
    }

    function test_later(uint256 dT) public {
        dT = bound(dT, Constant.MONTH * 11, type(uint256).max);
        this.setTarget(ID1, 3, Constant.MONTH * 12);
        vm.warp(block.timestamp + Constant.MONTH);
        this.setTarget(ID1, 3, dT);
        (uint256 tgt, uint256 dt) = this.getTarget(ID1);
        assertLe(dt, dT);
        assertEq(tgt, 3);
    }

    function test_pass_after() public {
        this.setTarget(ID1, 3, Constant.MONTH * 12);
        vm.warp(block.timestamp + Constant.MONTH * 12);
        this.setTarget(ID1, 6);
        (uint256 tgt, uint256 dt) = this.getTarget(ID1);
        assertEq(dt, Constant.MONTH * 0);
        assertEq(tgt, 6);
    }

    bytes4 immutable TOO_EARLY = TooEarly.selector;
    bytes4 immutable TOO_RETRO = TooRetro.selector;
}

contract SetTarget_Limited is TestParameterized {
    function test() public {
        bytes32 key = keccak256(abi.encodePacked(Selector.SET_TARGET, ID1));
        this.setTarget(ID1, 1);
        vm.expectRevert(abi.encodeWithSelector(LIMITED, key, Constant.MONTH));
        this.setTarget(ID1, 1);
    }

    function test_id_const() public {
        this.setTarget(ID1, 0);
        vm.warp(1 * Constant.MONTH + 1);
        this.setTarget(ID1, 1);
        vm.warp(2 * Constant.MONTH + 1);
        this.setTarget(ID1, 2);
    }

    function test_id_var() public {
        this.setTarget(ID1 + 0, 0);
        this.setTarget(ID1 + 1, 1);
        this.setTarget(ID1 + 2, 2);
    }

    bytes4 immutable LIMITED = ILimited.Limited.selector;
}

contract SetTarget_Unauthorized is TestParameterized {
    function setUp() public override {
        acma.grantRole(acma.ACMA_RELATE_ROLE(), self, 0);
        acma.relate(self, Selector.SET_TARGET, acma.POOL_SET_TARGET_ROLE());
        acma.relate(self, Selector.TMP_TARGET, acma.POOL_TMP_TARGET_ROLE());
        acma.revokeRole(acma.ACMA_RELATE_ROLE(), self);
    }

    function test() public {
        vm.expectRevert(abi.encodeWithSelector(AM_UNAUTHORIZED, self));
        this.setTarget(ID1, 1);
    }

    function test_with_duration() public {
        vm.expectRevert(abi.encodeWithSelector(AM_UNAUTHORIZED, self));
        this.setTarget(ID1, 1, 0);
    }

    bytes4 immutable AM_UNAUTHORIZED =
        IAccessManaged.AccessManagedUnauthorized.selector;
}
