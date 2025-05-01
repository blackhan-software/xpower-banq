// SPDX-License-Identifier: GPL-3.0
pragma solidity ^0.8.28;

import {IERC20Metadata} from "@openzeppelin/contracts/interfaces/IERC20Metadata.sol";
import {IERC20} from "@openzeppelin/contracts/interfaces/IERC20.sol";

import {IRModel} from "../struct/IRModel.sol";
import {IPoolRO} from "../interface/Pool.sol";

interface IPositionCap {
    /**
     * Sets the cap-limit of the position; over a duration.
     *
     * @param limit to set cap to
     * @param duration to set cap over (seconds)
     */
    function cap(uint256 limit, uint256 duration) external;

    /**
     * Gets the cap-limit of the position.
     *
     * @return limit position is capped at
     * @return duration of cap (seconds)
     */
    function cap() external view returns (uint256 limit, uint256 duration);

    /**
     * Gets the cap-limit of the position; for the user.
     *
     * @param user to get cap for
     * @return limit of the position
     * @return duration of cap (seconds)
     */
    function capOf(
        address user
    ) external view returns (uint256 limit, uint256 duration);
}

interface IPositionLock {
    /**
     * Gets user's locked position amount.
     *
     * @param user locked for
     * @return amount locked
     */
    function lockOf(address user) external view returns (uint256);
}

interface IPositionRO {
    /**
     * Gets the associated pool.
     * @return pool associated
     */
    function pool() external view returns (IPoolRO);

    /**
     * Gets the interest rate model.
     * @return irm structure
     */
    function model() external view returns (IRModel memory irm);

    /**
     * Gets the underlying asset.
     * @return asset underlying
     */
    function asset() external view returns (IERC20);

    /**
     * Gets the number of total holders.
     * @return number of total holders
     */
    function totalHolders() external view returns (uint256 number);

    /**
     * Gets the total balance; for the given user.
     *
     * @param user to query for
     * @return balance of the user
     */
    function totalOf(address user) external view returns (uint256 balance);
}

interface IPositionRW {
    /**
     * Mints tokens to the user.
     *
     * @param user to mint to
     * @param amount to mint
     * @param lock flag
     */
    function mint(address user, uint256 amount, bool lock) external;

    /**
     * Burns tokens from the user.
     *
     * @param user to burn from
     * @param amount to burn
     * @param unlock flag
     */
    function burn(address user, uint256 amount, bool unlock) external;
}

interface IPositionIndex {
    /**
     * Gets the index of the position.
     *
     * @return value of the index
     * @return dt duration since reindex (seconds)
     */
    function index() external view returns (uint256 value, uint256 dt);

    /**
     * Sets the index of the position.
     */
    function reindex() external;

    /**
     * Emitted on reindexing the position.
     *
     * @param value of the index
     * @param timestamp of the reindex
     * @param utilization of the position
     */
    event Reindex(uint256 value, uint256 timestamp, uint256 utilization);
}

interface IPosition is
    IERC20Metadata,
    IPositionIndex,
    IPositionLock,
    IPositionCap,
    IPositionRO,
    IPositionRW
{
    /** Thrown on constant cap. */
    error CapConstant(uint256 limit, uint256 duration);
    /** Thrown on exceeded cap (absolute). */
    error AbsExceeded(uint256 limit);
    /** Thrown on exceeded cap (relative). */
    error RelExceeded(uint256 limit);
    /** Thrown on forbidden transfer. */
    error ForbiddenTransfer(address from, address to);
    /** Thrown on insufficient health. */
    error InsufficientHealth(uint256 supply, uint256 borrow);
    /** Thrown on locked user balance. */
    error Locked(address user, uint256 balance);
}

interface ISupplyPosition is IPosition {}

interface IBorrowPosition is IPosition {}
