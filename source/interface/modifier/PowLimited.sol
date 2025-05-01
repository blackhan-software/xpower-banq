// SPDX-License-Identifier: GPL-3.0
pragma solidity ^0.8.29;

interface IPowLimited {
    /**
     * Thrown on premature function invocation.
     *
     * @param key hash of selector and arguments
     * @param difficulty of the pow-limit required (leading zeros)
     */
    error PowLimited(bytes32 key, uint256 difficulty);
}
