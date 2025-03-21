// SPDX-License-Identifier: GPL-3.0
pragma solidity ^0.8.29;

import {IDelayed} from "../../interface/modifier/Delayed.sol";

/**
 * Contract offers a `delay` modifier to enforce delayed
 * invocations (w.r.t. the given key).
 */
contract Delayed {
    mapping(bytes32 key => uint256) private _times;

    /**
     * Enforce a delay before a function invocation.
     *
     * @param dt duration of the delay (seconds)
     * @param key of the delayed function
     */
    modifier delayed(uint256 dt, bytes32 key) {
        uint256 yet = block.timestamp;
        // set timestamp (if not set or delay expired):
        // slither-disable-next-line incorrect-equality
        if (_times[key] == 0 || (yet > _times[key] + dt && dt > 0)) {
            uint256 timestamp = yet + dt;
            _times[key] = timestamp;
            emit IDelayed.Pending(key, timestamp);
        }
        // delay pending: revert invocation
        else if (_times[key] > yet) {
            revert IDelayed.Delayed(key, _times[key] - yet);
        }
        // delay expired: invoke and reset
        else {
            _;
            delete _times[key];
        }
    }

    /**
     * Gets the duration time and pending flag.
     *
     * @param key of the invocation
     * @return dt duration of the delay (seconds)
     * @return pending flag of the delay
     */
    function delayedOf(
        bytes32 key
    ) public view returns (uint256 dt, bool pending) {
        uint256 key_times = _times[key];
        uint256 yet = block.timestamp;
        if (key_times > yet) {
            return (key_times - yet, true);
        }
        return (yet - key_times, false);
    }
}
