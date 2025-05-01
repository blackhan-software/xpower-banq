// SPDX-License-Identifier: GPL-3.0
pragma solidity ^0.8.28;

import {SupplyPosition} from "../../source/contract/Position.sol";
import {BorrowPosition} from "../../source/contract/Position.sol";
import {VaultUtil} from "../../source/struct/VaultUtil.sol";
import {BaseTest} from "./Base.t.sol";

contract VaultTest_Util_90PCT is BaseTest {
    constructor() BaseTest(VAULT_FEE, IR_MODEL) {}

    function setUp() public {
        supply.cap(1e18 ** 2, 0);
        borrow.cap(9e17 ** 2, 0);
        supply.mint(self, 1e18, false);
        borrow.mint(self, 9e17, false);
    }
}

contract VaultTest_Util_90PCT_M12 is VaultTest_Util_90PCT {
    function test_util_M12() public {
        skip(12 * MONTH);
        assertEq(vault.util(), 0.900000_000000_000000e18);
    }

    function test_util_M12_S0() public {
        skip(12 * MONTH);
        supply.mint(self, 0, false);
        assertEq(vault.util(), 0.814353_676232_363616e18);
    }

    function test_util_M12_SB() public {
        skip(12 * MONTH);
        supply.mint(self, 0, false);
        borrow.mint(self, 0, false);
        assertEq(vault.util(), 0.891475_990289_048722e18);
    }

    function test_util_M12_B0() public {
        skip(12 * MONTH);
        borrow.mint(self, 0, false);
        assertEq(vault.util(), 0.994653_826268_082861e18);
    }

    function test_util_M12_BS() public {
        skip(12 * MONTH);
        borrow.mint(self, 0, false);
        supply.mint(self, 0, false);
        assertEq(vault.util(), 0.383949_228697_062749e18);
    }
}

contract VaultTest_Util_90PCT_6M is VaultTest_Util_90PCT {
    function test_util_M6() public {
        skip(6 * MONTH);
        assertEq(vault.util(), 0.900000_000000_000000e18);
    }

    function test_util_M6_S0() public {
        skip(6 * MONTH);
        supply.mint(self, 0, false);
        assertEq(vault.util(), 0.856106_482050_642608e18);
    }

    function test_util_M6_SB() public {
        skip(6 * MONTH);
        supply.mint(self, 0, false);
        borrow.mint(self, 0, false);
        assertEq(vault.util(), 0.897807_997818_942941e18);
    }

    function test_util_M6_B0() public {
        skip(6 * MONTH);
        borrow.mint(self, 0, false);
        assertEq(vault.util(), 0.946143_986738_421635e18);
    }

    function test_util_M6_BS() public {
        skip(6 * MONTH);
        borrow.mint(self, 0, false);
        supply.mint(self, 0, false);
        assertEq(vault.util(), 0.731243_729159_860572e18);
    }
}
