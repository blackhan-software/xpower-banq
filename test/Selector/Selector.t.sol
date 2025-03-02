// SPDX-License-Identifier: GPL-3.0
pragma solidity ^0.8.28;

import {IParameterized} from "../../source/interface/governance/Parameterized.sol";
import {Selectors} from "../../source/library/Selectors.sol";
import {Test} from "forge-std/Test.sol";

contract SelectorTest is Test {
    function test_set_target() public pure {
        assertEq(Selectors.SET_TARGET, IParameterized.setTarget.selector);
    }

    function test_cap_supply() public pure {
        bytes4 sel = bytes4(keccak256("capSupply(address,uint256)"));
        assertEq(Selectors.CAP_SUPPLY, sel);
    }

    function test_cap_borrow() public pure {
        bytes4 sel = bytes4(keccak256("capBorrow(address,uint256)"));
        assertEq(Selectors.CAP_BORROW, sel);
    }

    function test_tmp_supply() public pure {
        bytes4 sel = bytes4(keccak256("capSupply(address,uint256,uint256)"));
        assertEq(Selectors.TMP_SUPPLY, sel);
    }

    function test_tmp_borrow() public pure {
        bytes4 sel = bytes4(keccak256("capBorrow(address,uint256,uint256)"));
        assertEq(Selectors.TMP_BORROW, sel);
    }
}
