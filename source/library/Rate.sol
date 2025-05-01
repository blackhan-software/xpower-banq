// SPDX-License-Identifier: GPL-3.0
pragma solidity ^0.8.28;

import {ud, exp} from "@prb/math/src/UD60x18.sol";
import {IRModel} from "../struct/IRModel.sol";
import {Constant} from "./Constant.sol";

library BorrowRate {
    /**
     * Initializes the borrow rate structure.
     *
     * @param util rate
     * @param rate optimum
     * @param spread difference
     * @return irm structure
     */
    function init(
        uint256 util,
        uint256 rate,
        uint256 spread
    ) internal pure returns (IRModel memory irm) {
        return Rate.init(util, rate, spread);
    }

    /**
     * Accrues the amount with the borrow rate.
     *
     * @param irm structure
     * @param amount to accrue for
     * @param duration to accrue over
     * @param util to accrue for
     * @return compounded amount
     */
    function accrue(
        IRModel memory irm,
        uint256 amount,
        uint256 duration,
        uint256 util
    ) internal pure returns (uint256 compounded) {
        return Rate.accrue(amount, over(irm, duration, util));
    }

    /**
     * Accrues the borrow rate over the duration.
     *
     * @param irm structure
     * @param duration to accrue over
     * @param util to accrue for
     * @return borrow_rate accrued
     */
    function over(
        IRModel memory irm,
        uint256 duration,
        uint256 util
    ) internal pure returns (uint256 borrow_rate) {
        return Rate.over(duration, by(irm, util));
    }

    /**
     * Calculates the borrow rate.
     *
     * @param irm structure
     * @param util to calculate for
     * @return borrow_rate calculated
     */
    function by(
        IRModel memory irm,
        uint256 util
    ) internal pure returns (uint256 borrow_rate) {
        uint256 rate = Rate.by(util, irm.util, irm.rate);
        uint256 more = Constant.ONE + irm.spread;
        return (rate * more) / Constant.ONE;
    }
}

library SupplyRate {
    /**
     * Initializes the supply rate structure.
     *
     * @param util rate
     * @param rate optimum
     * @param spread difference
     * @return irm structure
     */
    function init(
        uint256 util,
        uint256 rate,
        uint256 spread
    ) internal pure returns (IRModel memory irm) {
        return Rate.init(util, rate, spread);
    }

    /**
     * Accrues the amount with the supply rate.
     *
     * @param irm structure
     * @param amount to accrue for
     * @param duration to accrue over
     * @param util to accrue for
     * @return compounded amount
     */
    function accrue(
        IRModel memory irm,
        uint256 amount,
        uint256 duration,
        uint256 util
    ) internal pure returns (uint256 compounded) {
        return Rate.accrue(amount, over(irm, duration, util));
    }

    /**
     * Accrues the supply rate over the duration.
     *
     * @param irm structure
     * @param duration to accrue over
     * @param util to accrue for
     * @return supply_rate accrued
     */
    function over(
        IRModel memory irm,
        uint256 duration,
        uint256 util
    ) internal pure returns (uint256 supply_rate) {
        return Rate.over(duration, by(irm, util));
    }

    /**
     * Calculates the supply rate.
     *
     * @param irm structure
     * @param util to calculate for
     * @return supply_rate calculated
     */
    function by(
        IRModel memory irm,
        uint256 util
    ) internal pure returns (uint256 supply_rate) {
        uint256 rate = Rate.by(util, irm.util, irm.rate);
        uint256 less = Constant.ONE - irm.spread;
        return (rate * less) / Constant.ONE;
    }
}

library Rate {
    /**
     * Initializes the rate structure.
     *
     * @param util rate
     * @param rate optimum
     * @param spread difference
     * @return irm structure
     */
    function init(
        uint256 util,
        uint256 rate,
        uint256 spread
    ) internal pure returns (IRModel memory irm) {
        require(util >= rate, InvalidOptimum(util, rate));
        return IRModel({rate: rate, spread: spread, util: util});
    }

    /**
     * Thrown if optimum utilization -vs- rate is invalid.
     */
    error InvalidOptimum(uint256 util, uint256 rate);

    /**
     * Accrues the amount for the rate.
     *
     * @param amount to accrue for
     * @param rate to accrue at
     * @return compounded amount
     */
    function accrue(
        uint256 amount,
        uint256 rate
    ) internal pure returns (uint256 compounded) {
        return ud(amount).mul(exp(ud(rate))).intoUint256();
    }

    /**
     * Accrues the rate over the duration.
     *
     * @param duration to accrue over
     * @param rate to accrue at
     * @return final_rate accrued
     */
    function over(
        uint256 duration,
        uint256 rate
    ) internal pure returns (uint256 final_rate) {
        return (rate * duration) / Constant.YEAR;
    }

    /**
     * Calculates the rate with a maximum of 200%.
     *
     * @param util current
     * @param util_optimal rate
     * @param rate_optimal for supply or borrow
     * @return rate calculated
     */
    function by(
        uint256 util,
        uint256 util_optimal,
        uint256 rate_optimal
    ) internal pure returns (uint256 rate) {
        if (util <= util_optimal && util_optimal > 0) {
            return (util * rate_optimal) / util_optimal;
        }
        assert(Constant.ONE >= util_optimal + 1);
        uint256 d1U = Constant.ONE - util_optimal;
        assert(Constant.ONE >= rate_optimal + 1);
        uint256 d1R = Constant.ONE - rate_optimal;
        assert(util_optimal >= rate_optimal);
        uint256 dUR = util_optimal - rate_optimal;
        // u×(1-R) >= 1×(U-R) because 0 < u > U
        uint256 pct = (util * d1R - Constant.ONE * dUR) / d1U;
        return pct > Constant.TWO ? Constant.TWO : pct;
    }
}
