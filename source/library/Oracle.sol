// SPDX-License-Identifier: GPL-3.0
pragma solidity ^0.8.29;

import {IERC20} from "@openzeppelin/contracts/interfaces/IERC20.sol";
import {Math} from "@openzeppelin/contracts/utils/math/Math.sol";
import {IOracle} from "../interface/Oracle.sol";

library Oracle {
    /**
     * Gets the maximum of the (bid, ask) quote.
     *
     * @param oracle to query
     * @param amount to quote for
     * @param source token
     * @param target token
     * @return max of (bid, ask) quote
     */
    function maxQuote(
        IOracle oracle,
        uint256 amount,
        IERC20 source,
        IERC20 target
    ) internal view returns (uint256 max) {
        (uint256 bid, uint256 ask) = oracle.getQuotes(amount, source, target);
        return Math.max(bid, ask);
    }

    /**
     * Gets the minimum of the (bid, ask) quote.
     *
     * @param oracle to query
     * @param amount to quote for
     * @param source token
     * @param target token
     * @return min of (bid, ask) quote
     */
    function minQuote(
        IOracle oracle,
        uint256 amount,
        IERC20 source,
        IERC20 target
    ) internal view returns (uint256 min) {
        (uint256 bid, uint256 ask) = oracle.getQuotes(amount, source, target);
        return Math.min(bid, ask);
    }
}
