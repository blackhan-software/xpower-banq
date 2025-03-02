// SPDX-License-Identifier: GPL-3.0
pragma solidity ^0.8.28;

import {Math} from "@openzeppelin/contracts/utils/math/Math.sol";
import {Quote} from "../struct/Quote.sol";
import {Constant} from "./Constant.sol";

/**
 * @title Time Weighted Average Price (TWAP)
 */
struct TWAP {
    Quote last;
    Quote mean;
}

library TWAPLib {
    /**
     * Initializes TWAP structure.
     *
     * @param quote initial (bid, ask, time) quote
     * @return twap structure
     */
    function init(Quote memory quote) internal pure returns (TWAP memory twap) {
        return TWAP({last: quote, mean: quote});
    }

    /**
     * Updates TWAP structure (using EWMA).
     *
     * @param twap structure to update
     * @param next (bid, ask, time) quote
     * @param decay factor (scaled by 1e18)
     * @return twap updated structure
     */
    function update(
        TWAP memory twap,
        Quote memory next,
        uint256 decay
    ) internal pure returns (TWAP memory) {
        assert(next.time >= twap.last.time);
        unchecked {
            if (next.time > twap.last.time) {
                Quote memory mean = twap.mean;
                Quote memory last = twap.last;
                if (mean.time == 0) {
                    mean.bid = next.bid;
                    mean.ask = next.ask;
                } else {
                    mean.bid =
                        Math.mulDiv(mean.bid, decay, ONE) +
                        Math.mulDiv(last.bid, ONE - decay, ONE);
                    mean.ask =
                        Math.mulDiv(mean.ask, decay, ONE) +
                        Math.mulDiv(last.ask, ONE - decay, ONE);
                }
                mean.time = next.time;
                twap.mean = mean;
            }
            twap.last = next;
            return twap;
        }
    }

    uint256 private constant ONE = Constant.ONE;
}
