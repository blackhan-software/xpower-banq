// SPDX-License-Identifier: GPL-3.0
pragma solidity 0.8.28;

import {Math} from "@openzeppelin/contracts/utils/math/Math.sol";

/**
 * Allows to integrate over an array of (stamp, value) tuples, and
 * to take the Δ-stamp weighted arithmetic mean over those values.
 */
library Integrator {
    struct Item {
        /** timestamp of value */
        uint256 stamp;
        /** value of interest */
        uint256 value;
        /** cumulative sum over Δ-stamps × values */
        uint256 area;
    }

    /**
     * @return head item (if any).
     */
    function headOf(Item[] storage items) internal view returns (Item memory) {
        return items.length > 0 ? items[0] : Item(0, 0, 0);
    }

    /**
     * @return last item (if any).
     */
    function lastOf(Item[] storage items) internal view returns (Item memory) {
        if (items.length > 0) {
            unchecked {
                return items[items.length - 1];
            }
        }
        return Item(0, 0, 0);
    }

    /**
     * Append (stamp, value) to items (with stamp >= last?.stamp).
     */
    function append(
        Item[] storage items,
        uint256 stamp,
        uint256 value
    ) internal {
        items.push(_nextOf(items, stamp, value));
    }

    /**
     * @return Δ-stamp weighted arithmetic mean of values (incl. next stamp & value).
     */
    function meanOf(
        Item[] storage items,
        uint256 stamp,
        uint256 value
    ) internal view returns (uint256) {
        Item memory head = headOf(items);
        if (stamp > head.stamp) {
            uint256 area = areaOf(items, stamp, value);
            if (area > 0) {
                if (area < type(uint256).max) {
                    unchecked {
                        return area / (stamp - head.stamp);
                    }
                }
                return type(uint256).max; // overflowed
            }
            return 0; // empty
        }
        return head.value;
    }

    /**
     * @return area of Δ-stamps × values (incl. next stamp & value).
     */
    function areaOf(
        Item[] storage items,
        uint256 stamp,
        uint256 value
    ) internal view returns (uint256) {
        if (items.length > 0) {
            unchecked {
                Item memory last = items[items.length - 1];
                uint256 area = _areaOf(value, stamp, last.stamp);
                (bool ok, uint256 next_area) = Math.tryAdd(last.area, area);
                if (!ok) next_area = type(uint256).max; // overflowed
                return next_area;
            }
        }
        return 0;
    }

    /**
     * @return next item (for stamp, value & meta).
     */
    function _nextOf(
        Item[] storage items,
        uint256 stamp,
        uint256 value
    ) private view returns (Item memory) {
        if (items.length > 0) {
            unchecked {
                Item memory last = items[items.length - 1];
                uint256 area = _areaOf(value, stamp, last.stamp);
                (bool ok, uint256 next_area) = Math.tryAdd(last.area, area);
                if (!ok) next_area = type(uint256).max; // overflowed
                return Item(stamp, value, next_area);
            }
        }
        return Item(stamp, value, 0);
    }

    /**
     * @return area equal to value * (stamp - last.stamp).
     */
    function _areaOf(
        uint256 value,
        uint256 stamp,
        uint256 last_stamp
    ) private pure returns (uint256) {
        assert(stamp >= last_stamp); // no time-travel
        unchecked {
            (bool ok, uint256 area) = Math.tryMul(value, stamp - last_stamp);
            if (!ok) area = type(uint256).max; // overflowed
            return area;
        }
    }
}
