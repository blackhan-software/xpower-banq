// SPDX-License-Identifier: GPL-3.0
pragma solidity ^0.8.29;

library Array {
    /**
     * Calculates the mean over an array of integers (w/o overflows).
     *
     * @param array of integers
     * @return mean of the array
     */
    function mean(uint256[] memory array) internal pure returns (uint256) {
        uint256 length = array.length;
        require(length > 0, Empty());
        uint256 item_sum = 0;
        uint256 rest_sum = 0;
        unchecked {
            for (uint256 i = 0; i < length; i++) {
                uint256 item = array[i];
                uint256 rest = item % length;
                uint256 diff = length - rest;
                if (rest_sum >= diff) {
                    item_sum += item / length + 1;
                    rest_sum -= diff;
                } else {
                    item_sum += item / length;
                    rest_sum += rest;
                }
            }
            return item_sum + rest_sum / length;
        }
    }

    /** Thrown on empty array. */
    error Empty();
}
