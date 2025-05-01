// SPDX-License-Identifier: GPL-3.0
pragma solidity ^0.8.29;

interface IDelayed {
    /**
     * Thrown on premature function invocation.
     *
     * @param key hash of selector and arguments
     * @param dt duration of the delay pending (seconds)
     */
    error Delayed(bytes32 key, uint256 dt);

    /**
     * Emitted on pending function invocation.
     *
     * @param key hash of selector and arguments
     * @param timestamp of pending invocation
     */
    event Pending(bytes32 indexed key, uint256 timestamp);
}
