// SPDX-License-Identifier: GPL-3.0
pragma solidity ^0.8.29;

import {PowLimitedLib} from "../../library/modifier/PowLimited.sol";
import {IPowLimited} from "../../interface/modifier/PowLimited.sol";

/**
 * Contract offers a `powlimited` modifier to enforce rate
 * limited invocations (w.r.t. the given difficulty).
 */
contract PowLimited {
    using PowLimitedLib for bytes32;

    constructor(uint256 cacheTime_) {
        _blockHash = blockhash(block.number - 1);
        _blockTime = block.timestamp;
        _cacheTime = cacheTime_;
    }

    /**
     * Enforces a rate-limit before a function invocation.
     * @param difficulty of proof-of-work expected
     */
    modifier powlimited(uint256 difficulty) {
        if (difficulty > 0) {
            bytes32 key = _blockHash.key(tx.origin, msg.data);
            if (key.zeros() < difficulty) {
                revert IPowLimited.PowLimited(key, difficulty);
            }
            unchecked {
                if (_cacheTime + _blockTime < block.timestamp) {
                    _blockHash = blockhash(block.number - 1);
                    _blockTime = block.timestamp;
                }
            }
        }
        _;
    }

    /**
     * Gets the cached block-hash of a recent block.
     */
    function blockHash() public view returns (bytes32) {
        return _blockHash;
    }

    bytes32 private _blockHash; // of recent block
    uint256 private _blockTime; // of recent block
    uint256 private immutable _cacheTime;
}
