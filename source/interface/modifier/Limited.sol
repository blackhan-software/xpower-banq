// SPDX-License-Identifier: GPL-3.0
pragma solidity ^0.8.29;

interface ILimited {
    /**
     * Thrown on premature function invocation.
     *
     * @param key hash of selector and arguments
     * @param dt duration of the limit pending (seconds)
     */
    error Limited(bytes32 key, uint256 dt);
}
