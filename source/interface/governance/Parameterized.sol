// SPDX-License-Identifier: GPL-3.0
pragma solidity ^0.8.29;

interface IParameterized {
    /**
     * Gets the parameter value (for given identifier).
     *
     * @param id of the parameter
     * @return value of the parameter
     */
    function parameterOf(uint256 id) external view returns (uint256 value);

    /**
     * Gets the parameter target (for given identifier).
     *
     * @param id of the parameter target
     * @return value of the parameter target
     * @return duration of the parameter target (seconds)
     */
    function getTarget(
        uint256 id
    ) external view returns (uint256 value, uint256 duration);

    /**
     * Sets the parameter target (for given identifier).
     *
     * @param id of the parameter target
     * @param value of the parameter target
     */
    function setTarget(uint256 id, uint256 value) external;

    /**
     * Sets the parameter target (for given identifier).
     *
     * @param id of the parameter target
     * @param value of the parameter target
     * @param duration of the parameter target (seconds)
     */
    function setTarget(uint256 id, uint256 value, uint256 duration) external;

    /** Thrown on target value too early. */
    error TooEarly(uint256 id, uint256 value, uint256 duration);
    /** Thrown on target value too retro. */
    error TooRetro(uint256 id, uint256 value, uint256 duration);
    /** Thrown on target value too large. */
    error TooLarge(uint256 id, uint256 value, uint256 max);
    /** Thrown on target value too small. */
    error TooSmall(uint256 id, uint256 value, uint256 min);
    /** Thrown on target identifier unknown. */
    error Unknown(uint256 id);

    /** Emitted on set-target (for given identifier). */
    event Target(uint256 indexed id, uint256 value, uint256 duration);
}
