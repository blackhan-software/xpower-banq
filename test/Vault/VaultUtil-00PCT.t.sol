// SPDX-License-Identifier: GPL-3.0
pragma solidity ^0.8.29;

import {VaultUtil} from "../../source/struct/VaultUtil.sol";
import {stdError} from "forge-std/Test.sol";
import {BaseTest} from "./Base.t.sol";

contract VaultTest_Util_00PCT is BaseTest {
    constructor() BaseTest(VAULT_FEE, IR_MODEL) {}

    function test_util() public view {
        assertEq(vault.util(), 0);
    }
}
