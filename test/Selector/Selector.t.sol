// SPDX-License-Identifier: GPL-3.0
pragma solidity ^0.8.29;

import {IParameterized} from "../../source/interface/governance/Parameterized.sol";
import {Selector} from "../../source/library/Selector.sol";
import {Test} from "forge-std/Test.sol";

contract SelectorTest is Test {
    function test_cap_supply() public pure {
        bytes4 sel = bytes4(keccak256("capSupply(address,uint256)"));
        assertEq(Selector.CAP_SUPPLY, sel);
    }

    function test_tmp_supply() public pure {
        bytes4 sel = bytes4(keccak256("capSupply(address,uint256,uint256)"));
        assertEq(Selector.TMP_SUPPLY, sel);
    }

    function test_cap_borrow() public pure {
        bytes4 sel = bytes4(keccak256("capBorrow(address,uint256)"));
        assertEq(Selector.CAP_BORROW, sel);
    }

    function test_tmp_borrow() public pure {
        bytes4 sel = bytes4(keccak256("capBorrow(address,uint256,uint256)"));
        assertEq(Selector.TMP_BORROW, sel);
    }

    function test_set_target() public pure {
        bytes4 sel = bytes4(keccak256("setTarget(uint256,uint256)"));
        assertEq(Selector.SET_TARGET, sel);
    }

    function test_tmp_target() public pure {
        bytes4 sel = bytes4(keccak256("setTarget(uint256,uint256,uint256)"));
        assertEq(Selector.TMP_TARGET, sel);
    }
}
