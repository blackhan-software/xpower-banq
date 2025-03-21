// SPDX-License-Identifier: GPL-3.0
pragma solidity ^0.8.29;

import {SupplyPosition} from "../../source/contract/Position.sol";
import {BorrowPosition} from "../../source/contract/Position.sol";
import {VaultUtil} from "../../source/struct/VaultUtil.sol";
import {BaseTest} from "./Base.t.sol";

contract VaultTest_Util_45PCT is BaseTest {
    constructor() BaseTest(VAULT_FEE, IR_MODEL) {}

    function setUp() public {
        supply.cap(10e17 ** 2, 0);
        borrow.cap(45e16 ** 2, 0);
        supply.mint(self, 10e17, false);
        borrow.mint(self, 45e16, false);
    }
}

contract VaultTest_Util_45PCT_12M is VaultTest_Util_45PCT {
    function test_util_M12() public {
        skip(12 * MONTH);
        assertEq(vault.util(), 0.450000_000000_000000e18);
    }

    function test_util_M12_S0() public {
        skip(12 * MONTH);
        supply.mint(self, 0, false);
        assertEq(vault.util(), 0.428053_241025_321304e18);
    }

    function test_util_M12_SB() public {
        skip(12 * MONTH);
        supply.mint(self, 0, false);
        borrow.mint(self, 0, false);
        assertEq(vault.util(), 0.448903_998909_471470e18);
    }

    function test_util_M12_B0() public {
        skip(12 * MONTH);
        borrow.mint(self, 0, false);
        assertEq(vault.util(), 0.473071_993369_210817e18);
    }

    function test_util_M12_BS() public {
        skip(12 * MONTH);
        borrow.mint(self, 0, false);
        supply.mint(self, 0, false);
        assertEq(vault.util(), 0.448847_877726_803081e18);
    }
}

contract VaultTest_Util_45PCT_6M is VaultTest_Util_45PCT {
    function test_util_M6() public {
        skip(6 * MONTH);
        assertEq(vault.util(), 0.450000_000000_000000e18);
    }

    function test_util_M6_S0() public {
        skip(6 * MONTH);
        supply.mint(self, 0, false);
        assertEq(vault.util(), 0.438889_460412_749701e18);
    }

    function test_util_M6_SB() public {
        skip(6 * MONTH);
        supply.mint(self, 0, false);
        borrow.mint(self, 0, false);
        assertEq(vault.util(), 0.449722_322217_745913e18);
    }

    function test_util_M6_B0() public {
        skip(6 * MONTH);
        borrow.mint(self, 0, false);
        assertEq(vault.util(), 0.461391_804235_992978e18);
    }

    function test_util_M6_BS() public {
        skip(6 * MONTH);
        borrow.mint(self, 0, false);
        supply.mint(self, 0, false);
        assertEq(vault.util(), 0.449715_294995_371851e18);
    }
}
