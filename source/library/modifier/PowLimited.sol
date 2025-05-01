// SPDX-License-Identifier: GPL-3.0
pragma solidity ^0.8.29;

import {Math} from "@openzeppelin/contracts/utils/math/Math.sol";

library PowLimitedLib {
    /**
     * Gets the number of leading zeros in a hash.
     *
     * @param hashed data bytes to check
     * @return count of leading zeros
     */
    function zeros(bytes32 hashed) internal pure returns (uint8 count) {
        if (hashed > 0) {
            unchecked {
                return uint8(63 - (Math.log2(uint256(hashed)) >> 2));
            }
        }
        return 64;
    }

    /**
     * Gets the key for the given block-hash et al.
     *
     * @param blockHash of the recent block
     * @param sender of the message
     * @param data of the message
     * @return key of block-hash
     */
    function key(
        bytes32 blockHash,
        address sender,
        bytes memory data
    ) internal pure returns (bytes32) {
        return keccak256(abi.encodePacked(blockHash, sender, data));
    }
}
