// SPDX-License-Identifier: GPL-3.0
pragma solidity ^0.8.29;

import {IRateLimited} from "../../interface/modifier/RateLimited.sol";

/**
 * Contract offers a `ratelimited` modifier to enforce rate
 * limited invocations (w.r.t. the given key).
 */
contract RateLimited {
    mapping(bytes32 key => uint256) private _times;
    mapping(bytes32 key => uint256) private _total;
    mapping(bytes32 key => uint256) private _floor;

    /**
     * Enforces a rate-limit before a function invocation.
     *
     * @param max_capacity that can be accumulated (seconds)
     * @param floor_cost per function invocation (seconds)
     * @param key of the limited function
     */
    modifier ratelimited(
        uint256 max_capacity,
        uint256 floor_cost,
        bytes32 key
    ) {
        uint256 yet = block.timestamp;
        // cap regeneration
        if (_times[key] > 0) {
            _total[key] += yet - _times[key];
        } else {
            _total[key] = max_capacity;
        }
        if (_total[key] > max_capacity) {
            _total[key] = max_capacity;
        }
        // cap enforcement
        if (_total[key] < floor_cost) {
            revert IRateLimited.RateLimited(key, floor_cost - _total[key]);
        }
        // store base-cost
        // slither-disable-next-line incorrect-equality
        if (_floor[key] == 0 && floor_cost > 0) {
            _floor[key] = floor_cost;
        }
        _;
        _times[key] = yet;
        _total[key] -= floor_cost;
    }

    /**
     * Gets the duration time and pending flag.
     *
     * @param key of the invocation
     * @return total_cap of the limit (seconds)
     * @return pending flag of the limit
     */
    function ratelimitedOf(
        bytes32 key
    ) public view returns (uint256 total_cap, bool pending) {
        uint256 yet = block.timestamp;
        // slither-disable-next-line incorrect-equality
        if (_total[key] == 0 && _times[key] > 0) {
            return (0, yet - _times[key] < _floor[key]);
        }
        return (_total[key], false);
    }
}
