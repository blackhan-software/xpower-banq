// SPDX-License-Identifier: GPL-3.0
pragma solidity ^0.8.29;

/**
 * @dev https://github.com/traderjoe-xyz/joe-v2/blob/main/src/interfaces/IJoePair.sol
 */
interface IPair_V1 {
    /**
     * Gets the reserves of the pair.
     *
     * @return reserve0 of token0
     * @return reserve1 of token1
     * @return timestamp of the reserves
     */
    function getReserves()
        external
        view
        returns (uint112 reserve0, uint112 reserve1, uint32 timestamp);

    /**
     * @return token0 of pair
     */
    function token0() external view returns (address);

    /**
     * @return token1 of pair
     */
    function token1() external view returns (address);
}
