// SPDX-License-Identifier: GPL-3.0
pragma solidity ^0.8.29;

import {IParameterized} from "../../source/interface/governance/Parameterized.sol";
import {Constant} from "../../source/library/Constant.sol";
import {VaultFee} from "../../source/struct/VaultFee.sol";
import {BaseTest} from "./Base.t.sol";

contract SupervisedTarget is BaseTest {
    constructor() BaseTest(VAULT_FEE, IR_MODEL) {}

    function setUp() public virtual {
        acma.grantRole(acma.VAULT_SET_TARGET_ROLE(), self, 0);
        vm.warp(block.timestamp + Constant.MONTH * 3);
    }

    function VAULT_MAX() internal pure returns (VaultFee memory) {
        return
            VaultFee({
                entry: Constant.HLF,
                entryRecipient: address(0),
                exit: Constant.HLF,
                exitRecipient: address(0)
            });
    }

    function VAULT_MIN() internal pure returns (VaultFee memory) {
        return
            VaultFee({
                entry: Constant.NIL,
                entryRecipient: address(0),
                exit: Constant.NIL,
                exitRecipient: address(0)
            });
    }

    bytes4 immutable TOO_LARGE = IParameterized.TooLarge.selector;
    bytes4 immutable TOO_SMALL = IParameterized.TooSmall.selector;
}

contract SupervisedTarget_EntryFee is SupervisedTarget {
    function test_fee(uint256 fee) public {
        fee = bound(fee, VAULT_FEE.entry / 2, VAULT_FEE.entry * 2);
        vault.setTarget(vault.FEE_ENTRY_ID(), fee);
    }

    function test_fee_event(uint256 fee) public {
        fee = bound(fee, VAULT_FEE.entry / 2, VAULT_FEE.entry * 2);
        vm.expectEmit();
        emit IParameterized.Target(vault.FEE_ENTRY_ID(), fee, 0);
        vault.setTarget(vault.FEE_ENTRY_ID(), fee);
        (uint tgt, ) = vault.getTarget(vault.FEE_ENTRY_ID());
        assertEq(tgt, fee);
    }

    function test_fee_gt_max() public {
        reset(VAULT_MAX(), IR_MODEL);
        vm.warp(block.timestamp + Constant.MONTH * 3);
        acma.grantRole(acma.VAULT_SET_TARGET_ROLE(), self, 0);
        (uint id, uint max) = (vault.FEE_ENTRY_ID(), Constant.HLF);
        vm.expectRevert(abi.encodeWithSelector(TOO_LARGE, id, max + 1, max));
        vault.setTarget(id, max + 1);
    }

    function test_fee_eq_min() public {
        reset(VAULT_MIN(), IR_MODEL);
        vm.warp(block.timestamp + Constant.MONTH * 3);
        acma.grantRole(acma.VAULT_SET_TARGET_ROLE(), self, 0);
        (uint id, uint min) = (vault.FEE_ENTRY_ID(), Constant.NIL);
        vault.setTarget(id, min); // min=0
    }
}

contract SupervisedTarget_ExitFee is SupervisedTarget {
    function test_fee(uint256 fee) public {
        fee = bound(fee, VAULT_FEE.entry / 2, VAULT_FEE.entry * 2);
        vault.setTarget(vault.FEE_EXIT_ID(), fee);
    }

    function test_fee_event(uint256 fee) public {
        fee = bound(fee, VAULT_FEE.entry / 2, VAULT_FEE.entry * 2);
        vm.expectEmit();
        emit IParameterized.Target(vault.FEE_EXIT_ID(), fee, 0);
        vault.setTarget(vault.FEE_EXIT_ID(), fee);
        (uint tgt, ) = vault.getTarget(vault.FEE_EXIT_ID());
        assertEq(tgt, fee);
    }

    function test_fee_gt_max() public {
        reset(VAULT_MAX(), IR_MODEL);
        vm.warp(block.timestamp + Constant.MONTH * 3);
        acma.grantRole(acma.VAULT_SET_TARGET_ROLE(), self, 0);
        (uint id, uint max) = (vault.FEE_EXIT_ID(), Constant.HLF);
        vm.expectRevert(abi.encodeWithSelector(TOO_LARGE, id, max + 1, max));
        vault.setTarget(id, max + 1);
    }

    function test_fee_eq_min() public {
        reset(VAULT_MIN(), IR_MODEL);
        vm.warp(block.timestamp + Constant.MONTH * 3);
        acma.grantRole(acma.VAULT_SET_TARGET_ROLE(), self, 0);
        (uint id, uint min) = (vault.FEE_EXIT_ID(), Constant.NIL);
        vault.setTarget(id, min); // min=0
    }
}

contract SupervisedTarget_Unknown is SupervisedTarget {
    function test_unknown() public {
        vm.expectRevert(abi.encodeWithSelector(TGT_UNKNOWN, 0x0));
        vault.setTarget(0x0, 0);
    }

    bytes4 immutable TGT_UNKNOWN = IParameterized.Unknown.selector;
}
