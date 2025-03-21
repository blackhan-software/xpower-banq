// SPDX-License-Identifier: GPL-3.0
pragma solidity ^0.8.29;

import {IERC20Metadata} from "@openzeppelin/contracts/interfaces/IERC20Metadata.sol";

import {IRModel} from "../../source/struct/IRModel.sol";
import {VaultFee} from "../../source/struct/VaultFee.sol";
import {Quote} from "../../source/struct/Quote.sol";

import {ISupplyPosition} from "../../source/interface/Position.sol";
import {IBorrowPosition} from "../../source/interface/Position.sol";
import {IOracle} from "../../source/interface/Oracle.sol";
import {IVault} from "../../source/interface/Vault.sol";

import {BaseTest} from "./Base.t.sol";

contract PoolTest is BaseTest {
    ISupplyPosition immutable sAVAX;
    ISupplyPosition immutable sUSDC;
    IBorrowPosition immutable bAVAX;
    IBorrowPosition immutable bUSDC;
    IVault immutable vAVAX;
    IVault immutable vUSDC;

    constructor(
        IERC20Metadata[] memory tokens_,
        VaultFee memory fee_,
        IRModel memory model_,
        IOracle oracle_
    ) BaseTest(tokens_, fee_, model_, oracle_) {
        acma.grantRole(acma.POOL_TMP_SUPPLY_ROLE(), self, 0);
        acma.grantRole(acma.POOL_TMP_BORROW_ROLE(), self, 0);
        pool.capSupply(AVAX, type(uint224).max, 0);
        pool.capBorrow(AVAX, type(uint224).max, 0);
        pool.capSupply(USDC, type(uint224).max, 0);
        pool.capBorrow(USDC, type(uint224).max, 0);
        sAVAX = pool.supplyOf(AVAX);
        sUSDC = pool.supplyOf(USDC);
        bAVAX = pool.borrowOf(AVAX);
        bUSDC = pool.borrowOf(USDC);
        vAVAX = pool.vaultOf(AVAX);
        vUSDC = pool.vaultOf(USDC);
    }

    function set_avaxusdc(uint256 usdc, uint256 avax) internal {
        Quote memory a2u = Quote({bid: avax, ask: usdc, time: block.timestamp});
        DELPHI.setQuote(a2u, AVAX, USDC);
        Quote memory u2a = Quote({bid: usdc, ask: avax, time: block.timestamp});
        DELPHI.setQuote(u2a, USDC, AVAX);
    }
}
