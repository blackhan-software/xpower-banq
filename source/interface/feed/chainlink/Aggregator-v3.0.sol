// SPDX-License-Identifier: MIT
pragma solidity ^0.8.28;

/**
 * @dev https://github.com/smartcontractkit/chainlink/blob/develop/contracts/src/v0.8/shared/interfaces/AggregatorV3Interface.sol
 */
interface IAggregator_V3 {
    /**
     * Gets the decimals of the aggregator.
     * @return decimals of aggregator
     */
    function decimals() external view returns (uint8);

    /**
     * @return description the description of the aggregator
     */
    function description() external view returns (string memory);

    /**
     * Gets the latest round data.
     *
     * @param id to retrieve the data for
     * @return roundId identifier
     * @return answer for the round
     * @return startedAt timestamp when the round started
     * @return updatedAt timestamp when the round was updated
     */
    function getRoundData(
        uint80 id
    )
        external
        view
        returns (
            uint80 roundId,
            int256 answer,
            uint256 startedAt,
            uint256 updatedAt,
            /// @deprecated
            uint80 inRound
        );

    /**
     * Gets the latest round data.
     *
     * @return roundId identifier
     * @return answer for the round
     * @return startedAt timestamp when the round started
     * @return updatedAt timestamp when the round updated
     */
    function latestRoundData()
        external
        view
        returns (
            uint80 roundId,
            int256 answer,
            uint256 startedAt,
            uint256 updatedAt,
            /// @deprecated
            uint80 inRound
        );

    /**
     * Gets the version of the aggregator.
     * @return version of aggregator
     */
    function version() external view returns (uint256);
}
