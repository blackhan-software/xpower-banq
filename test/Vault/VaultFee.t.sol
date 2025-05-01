// SPDX-License-Identifier: GPL-3.0
pragma solidity ^0.8.28;

import {IERC20Metadata} from "@openzeppelin/contracts/interfaces/IERC20Metadata.sol";
import {IVault, IFeeVault} from "../../source/interface/Vault.sol";

import {VaultFee} from "../../source/struct/VaultFee.sol";
import {stdError} from "forge-std/Test.sol";
import {BaseTest} from "./Base.t.sol";

contract VaultTest_Fee is BaseTest {
    constructor() BaseTest(VAULT_FEE, IR_MODEL) {}

    function test_name() public view {
        IERC20Metadata meta = IERC20Metadata(address(vault));
        assertEq(meta.name(), "Token Vault");
    }

    function test_symbol() public view {
        IERC20Metadata meta = IERC20Metadata(address(vault));
        assertEq(meta.symbol(), "vTKN");
    }

    function test_fee() public view {
        VaultFee memory fee = vault.fee();
        assertEq(fee.entry, 10 * BPS);
        assertEq(fee.entryRecipient, address(vault));
        assertEq(fee.exit, 10 * BPS);
        assertEq(fee.exitRecipient, address(vault));
    }
}

contract VaultTest_Deposit is BaseTest {
    constructor() BaseTest(VAULT_FEE, IR_MODEL) {}

    function test_previewDeposit() public view {
        uint256 preview = vault.previewDeposit(ONE + 10 * BPS);
        assertEq(preview, 1_000000_000000_000000.000000000e9);
    }

    function test_deposit() public {
        token.approve(address(vault), ONE + 10 * BPS);
        vault.deposit(ONE + 10 * BPS, self);
        ///
        uint256 balance = vault.balanceOf(self);
        assertEq(balance, 1_000000_000000_000000.000000000e9);
        uint256 total = vault.totalAssets();
        assertEq(total, ONE + 10 * BPS);
    }
}

contract VaultTest_Withdraw is BaseTest {
    constructor() BaseTest(VAULT_FEE, IR_MODEL) {}

    function setUp() public {
        token.approve(address(vault), ONE + 10 * BPS);
        vault.deposit(ONE + 10 * BPS, self);
    }

    function test_previewWithdraw() public view {
        uint256 preview = vault.previewWithdraw(ONE - 1);
        assertEq(preview, 999999_999999_999999.001998002e9);
    }

    function test_withdraw() public {
        vault.withdraw(ONE - 1, self, self);
        ///
        uint256 balance = vault.balanceOf(self);
        assertEq(balance, 0.998001998e9);
        uint256 total = vault.totalAssets();
        assertEq(total, 10 * BPS + 1);
    }
}

contract VaultTest_Mint is BaseTest {
    constructor() BaseTest(VAULT_FEE, IR_MODEL) {}

    function setUp() public {
        token.approve(address(vault), ONE + 10 * BPS);
        vault.deposit(ONE + 10 * BPS, self);
    }

    function test_previewMint() public view {
        uint256 preview = vault.previewMint(ONE);
        assertEq(preview, 1.002001000e9);
    }

    function test_mint() public {
        token.approve(address(vault), ONE + 20 * BPS);
        vault.mint(ONE, self);
        ///
        uint256 balance = vault.balanceOf(self);
        assertEq(balance, 1_000000_001000_000000.000000000e9);
        uint256 total = vault.totalAssets();
        assertEq(total, 1001_000001.002001000e9);
    }
}

contract VaultTest_Redeem is BaseTest {
    constructor() BaseTest(VAULT_FEE, IR_MODEL) {}

    function setUp() public {
        token.approve(address(vault), ONE + 10 * BPS);
        vault.deposit(ONE + 10 * BPS, self);
    }

    function test_previewRedeem() public view {
        uint256 preview = vault.previewRedeem(ONE);
        assertEq(preview, 0.999999999e9);
    }

    function test_redeem() public {
        vault.redeem(ONE, self, self);
        ///
        uint256 balance = vault.balanceOf(self);
        assertEq(balance, 999999_999000_000000.000000000e9);
        uint256 total = vault.totalAssets();
        assertEq(total, 1000_999999.000000001e9);
    }
}
