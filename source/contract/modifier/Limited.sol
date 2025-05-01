// SPDX-License-Identifier: GPL-3.0
pragma solidity ^0.8.28;

import {ILimited} from "../../interface/modifier/Limited.sol";

/**
 * Contract offers a `limited` modifier to enforce rate
 * limited invocations (w.r.t. the given key).
 */
contract Limited {
    mapping(bytes32 key => uint256) private _times;

    /**
     * Enforces a rate-limit before a function invocation.
     *
     * @param dt duration of the limit (seconds)
     * @param key of the limited function
     */
    modifier limited(uint256 dt, bytes32 key) {
        uint256 yet = block.timestamp;
        // limit pending: revert invocation
        if (_times[key] > yet) {
            revert ILimited.Limited(key, _times[key] - yet);
        }
        _;
        // limit expired: reset timestamp
        _times[key] = yet + dt;
    }

    /**
     * Gets the duration time and pending flag.
     *
     * @param key of the invocation
     * @return dt duration of the limit (seconds)
     * @return pending flag of the limit
     */
    function limitedOf(
        bytes32 key
    ) public view returns (uint256 dt, bool pending) {
        uint256 yet = block.timestamp;
        if (_times[key] > yet) {
            return (_times[key] - yet, true);
        }
        return (yet - _times[key], false);
    }
}
