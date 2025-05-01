// SPDX-License-Identifier: GPL-3.0
pragma solidity ^0.8.28;

/**
 * @dev https://github.com/traderjoe-xyz/joe-v2/blob/main/src/interfaces/ILBPair.sol
 */
interface IPair_V2 {
    /**
     * Gets the swap information of the pair.
     *
     * @param amount_out to swap out
     * @param swap_forY flag for token to swap (true: tokenY, false: tokenX)
     * @return amount_in swapped in
     * @return out_left unswapped amount
     * @return fee charged
     */
    function getSwapIn(
        uint128 amount_out,
        bool swap_forY
    ) external view returns (uint128 amount_in, uint128 out_left, uint128 fee);

    /**
     * Gets the swap information of the pair.
     *
     * @param amount_in to swap in
     * @param swap_forY flag for token to swap (true: tokenY, false: tokenX)
     * @return in_left unswapped amount
     * @return amount_out swapped out
     * @return fee charged
     */
    function getSwapOut(
        uint128 amount_in,
        bool swap_forY
    ) external view returns (uint128 in_left, uint128 amount_out, uint128 fee);

    /**
     * @return tokenX of pair
     */
    function getTokenX() external view returns (address tokenX);

    /**
     * @return tokenY of pair
     */
    function getTokenY() external view returns (address tokenY);
}
