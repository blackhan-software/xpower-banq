// SPDX-License-Identifier: GPL-3.0
pragma solidity ^0.8.28;

import {IERC20} from "@openzeppelin/contracts/interfaces/IERC20.sol";
import {IWPosition} from "../../interface/WPosition.sol";
import {WPosition} from "../../contract/WPosition.sol";
import {IPool} from "../../interface/Pool.sol";

library WSupplyPositionMill {
    function wsupply(IPool pool, IERC20 token) internal returns (IWPosition) {
        return new WPosition(pool.supplyOf(token));
    }
}

library WBorrowPositionMill {
    function wborrow(IPool pool, IERC20 token) internal returns (IWPosition) {
        return new WPosition(pool.borrowOf(token));
    }
}
