// SPDX-License-Identifier: GPL-3.0
pragma solidity ^0.8.29;

import {VaultMill} from "../../source/library/mill/Vault.sol";
import {RateLimit} from "../../source/struct/RateLimit.sol";
import {VaultFee} from "../../source/struct/VaultFee.sol";
import {IRModel} from "../../source/struct/IRModel.sol";
import {Weight} from "../../source/struct/Weight.sol";

import {IVault} from "../../source/interface/Vault.sol";
import {IPool} from "../../source/interface/Pool.sol";
import {IAcma} from "../../source/interface/Acma.sol";
import {BaseScript} from "../base.s.sol";

contract Run is BaseScript {
    function run(
        uint256 pool_index,
        string memory symbol,
        uint256 index
    ) external {
        IAcma acma = IAcma(addressOf("ACMA"));
        IPool pool = IPool(addressOf(zeropad("P", pool_index, 3)));
        IRModel memory irm = irmOf(symbol);
        VaultFee memory fee = vaultFeeOf(symbol);
        Weight memory weight = weightOf(symbol);
        RateLimit memory limit = rateLimitOf(symbol);
        vm.startBroadcast();
        IVault vault = VaultMill.vault(pool, index, irm, fee, acma);
        acma.grantRole(acma.POOL_ENLIST_ADMIN_ROLE(), msg.sender, 0);
        acma.grantRole(acma.POOL_ENLIST_ROLE(), msg.sender, 0);
        pool.enlist(index, vault, weight, limit);
        acma.revokeRole(acma.POOL_ENLIST_ROLE(), msg.sender);
        acma.revokeRole(acma.POOL_ENLIST_ADMIN_ROLE(), msg.sender);
        vm.stopBroadcast();
    }
}
