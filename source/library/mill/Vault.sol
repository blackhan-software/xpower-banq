// SPDX-License-Identifier: GPL-3.0
pragma solidity ^0.8.29;

import {IAccessManager} from "@openzeppelin/contracts/access/manager/AccessManager.sol";
import {IERC20Metadata} from "@openzeppelin/contracts/interfaces/IERC20Metadata.sol";

import {ISupplyPosition} from "../../interface/Position.sol";
import {IBorrowPosition} from "../../interface/Position.sol";
import {IVault} from "../../interface/Vault.sol";
import {IPool} from "../../interface/Pool.sol";

import {SupplyPosition} from "../../contract/Position.sol";
import {BorrowPosition} from "../../contract/Position.sol";
import {Vault} from "../../contract/Vault.sol";

import {VaultFee} from "../../struct/VaultFee.sol";
import {IRModel} from "../../struct/IRModel.sol";

library VaultMill {
    function vault(
        IPool pool,
        uint256 index,
        IRModel memory irm,
        VaultFee memory fee,
        IAccessManager acma
    ) internal returns (IVault) {
        IERC20Metadata[] memory tokens = pool.tokens();
        assert(tokens.length >= 2); // at least 2 tokens!
        IERC20Metadata buddy = tokens[index > 0 ? 0 : 1];
        IERC20Metadata token = tokens[index];
        ISupplyPosition sp = new SupplyPosition(pool, token, buddy, irm, acma);
        IBorrowPosition bp = new BorrowPosition(pool, token, buddy, irm, acma);
        return new Vault(address(pool), token, fee, sp, bp, acma);
    }
}
