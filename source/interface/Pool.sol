// SPDX-License-Identifier: GPL-3.0
pragma solidity ^0.8.29;

import {IERC20Metadata} from "@openzeppelin/contracts/interfaces/IERC20Metadata.sol";
import {IERC20} from "@openzeppelin/contracts/interfaces/IERC20.sol";

import {RateLimit} from "../struct/RateLimit.sol";
import {VaultFee} from "../struct/VaultFee.sol";
import {Health} from "../struct/Health.sol";
import {Weight} from "../struct/Weight.sol";

import {ISupplyPosition} from "./Position.sol";
import {IBorrowPosition} from "./Position.sol";
import {IWPosition} from "./WPosition.sol";
import {IOracle} from "./Oracle.sol";
import {IVault} from "./Vault.sol";

interface ISupervisedPoolCap {
    /**
     * Gets the supply-cap of the token; for the user.
     *
     * @param user to get cap for
     * @param token to get cap for
     *
     * @return limit of the token cap
     * @return dt duration of cap (seconds)
     */
    function capSupplyOf(
        address user,
        IERC20 token
    ) external returns (uint256 limit, uint256 dt);

    /**
     * Gets the supply-cap of the token.
     *
     * @param token to get cap for
     * @return limit of the token cap
     * @return dt duration of cap (seconds)
     */
    function capSupply(
        IERC20 token
    ) external returns (uint256 limit, uint256 dt);

    /**
     * Sets the supply-cap of the token; over a duration.
     *
     * @param token to set cap for
     * @param limit to set token cap to
     * @param dt duration to set over (seconds)
     */
    function capSupply(IERC20 token, uint256 limit, uint256 dt) external;

    /**
     * Sets the supply-cap of the token.
     *
     * @param token to set cap for
     * @param cap limit to set to
     */
    function capSupply(IERC20 token, uint256 cap) external;

    /**
     * Gets the borrow-cap of the token; for the user.
     *
     * @param user to get cap for
     * @param token to get cap for
     *
     * @return limit limit of the token
     * @return dt duration of cap (seconds)
     */
    function capBorrowOf(
        address user,
        IERC20 token
    ) external returns (uint256 limit, uint256 dt);

    /**
     * Gets the borrow-cap of the token.
     *
     * @param token to get cap for
     * @return limit limit of the token
     * @return dt duration of cap (seconds)
     */
    function capBorrow(
        IERC20 token
    ) external returns (uint256 limit, uint256 dt);

    /**
     * Sets the borrow-cap of the token; over a duration.
     *
     * @param token to set cap for
     * @param limit limit to set to
     * @param dt duration to set over (seconds)
     */
    function capBorrow(IERC20 token, uint256 limit, uint256 dt) external;

    /**
     * Sets the borrow-cap of the token.
     *
     * @param token to set cap for
     * @param cap limit to set to
     */
    function capBorrow(IERC20 token, uint256 cap) external;
}

interface ISupervisedPoolRW {
    /**
     * Enlists a token into the pool; if pre-registered!
     *
     * @param index to enlist for
     * @param vault to enlist with
     * @param weight to enlist with
     * @param rate_limit to enlist with
     */
    function enlist(
        uint256 index,
        IVault vault,
        Weight memory weight,
        RateLimit memory rate_limit
    ) external;

    /**
     * Enwraps a token's supply-position.
     *
     * @param index to enwrap for
     * @param wposition to enwrap
     */
    function enwrap(uint256 index, IWPosition wposition) external;

    /**
     * Emitted on token enlist.
     *
     * @param token enlisted
     */
    event Enlist(IERC20 indexed token);

    /**
     * Emitted on token enwrap.
     *
     * @param token enwrapped
     */
    event Enwrap(IERC20 indexed token);
}

interface ISupervisedPoolRO {
    /**
     * Gets the enlistment status of the token.
     *
     * @param token to check for enlistment
     * @return flag whether the token is enlisted
     */
    function enlisted(IERC20 token) external view returns (bool flag);

    /**
     * Gets the unlistment status of the token.
     *
     * @param token to check for unlistment
     * @return flag whether the token is unlisted
     */
    function unlisted(IERC20 token) external view returns (bool flag);
}

interface ISupervisedPool is
    ISupervisedPoolCap,
    ISupervisedPoolRW,
    ISupervisedPoolRO
{}

interface IPoolRW {
    /**
     * Supplies tokens into the pool.
     *
     * @param token to supply
     * @param amount to supply
     */
    function supply(
        IERC20 token,
        uint256 amount
    ) external returns (uint256 assets);

    /**
     * Supplies tokens into the pool; with lock.
     *
     * @param token to supply
     * @param amount to supply
     * @param lock flag
     */
    function supply(
        IERC20 token,
        uint256 amount,
        bool lock
    ) external returns (uint256 assets);

    /**
     * Redeems tokens from the pool.
     *
     * @param token to redeem
     * @param amount to redeem
     */
    function redeem(
        IERC20 token,
        uint256 assets
    ) external returns (uint256 amount);

    /**
     * Borrows tokens from the pool.
     *
     * @param token to borrow
     * @param amount to borrow
     */
    function borrow(
        IERC20 token,
        uint256 assets
    ) external returns (uint256 amount);

    /**
     * Borrows tokens from the pool; with lock.
     *
     * @param token to borrow
     * @param amount to borrow
     * @param lock flag
     */
    function borrow(
        IERC20 token,
        uint256 assets,
        bool lock
    ) external returns (uint256 amount);

    /**
     * Borrows tokens from the pool; with lock and flash-loan.
     *
     * @param token to borrow
     * @param amount to borrow
     * @param lock flag
     * @param flash loan contract
     * @param data to forward
     */
    function borrow(
        IERC20 token,
        uint256 assets,
        bool lock,
        IFlash flash,
        bytes calldata data
    ) external returns (uint256 amount);

    /**
     * Settles tokens into the pool.
     *
     * @param token to settle
     * @param amount to settle
     */
    function settle(
        IERC20 token,
        uint256 assets
    ) external returns (uint256 amount);

    /**
     * Liquidates the victim, using the sender's tokens; partially.
     *
     * @param victim to liquidate mercilessly
     * @param partial_exp to liquidate with
     */
    function liquidate(address victim, uint8 partial_exp) external;

    /**
     * Liquidates the victim, using the sender's tokens; partially.
     *
     * @param user to liquidate with (sender or pool)
     * @param victim to liquidate mercilessly
     * @param partial_exp to liquidate with
     */
    function square(address user, address victim, uint8 partial_exp) external;
}

interface IPoolRO {
    /**
     * Gets the oracle of the pool.
     * @return oracle of the pool
     */
    function oracle() external view returns (IOracle);

    /**
     * Gets the list of tokens in the pool.
     * @return tokens in the pool
     */
    function tokens() external view returns (IERC20Metadata[] memory);

    /**
     * Gets the health of the user.
     *
     * @param user to query for
     * @return health of the user
     */
    function healthOf(address user) external view returns (Health memory);

    /**
     * Gets the supply position of the token.
     *
     * @return supply position of the token
     */
    function supplyOf(IERC20 token) external view returns (ISupplyPosition);

    /**
     * Gets the borrow position of the token.
     *
     * @param token to query for
     * @return borrow position of the token
     */
    function borrowOf(IERC20 token) external view returns (IBorrowPosition);

    /**
     * Gets user's locked supply position of the token.
     *
     * @param user locked for
     * @param token locked for
     * @return amount locked
     */
    function supplyLockOf(
        address user,
        IERC20 token
    ) external view returns (uint256);

    /**
     * Gets user's locked borrow position of the token.
     *
     * @param user locked for
     * @param token locked for
     * @return amount locked
     */
    function borrowLockOf(
        address user,
        IERC20 token
    ) external view returns (uint256);

    /**
     * Gets the supply difficulty for the token and amount.
     *
     * @param token to query for
     * @param amount to query for
     * @return difficulty of supply
     */
    function supplyDifficultyOf(
        IERC20 token,
        uint256 amount
    ) external view returns (uint256);

    /**
     * Gets the borrow difficulty for the token and amount.
     *
     * @param token to query for
     * @param amount to query for
     * @return difficulty of borrow
     */
    function borrowDifficultyOf(
        IERC20 token,
        uint256 amount
    ) external view returns (uint256);

    /**
     * Gets the liquidate difficulty for the partial exponent.
     *
     * @param partial_exp to query for
     * @return difficulty of liquidate
     */
    function liquidateDifficultyOf(
        uint8 partial_exp
    ) external view returns (uint256);

    /**
     * Gets the vault of the token.
     *
     * @param token to query for
     * @return vault of the token
     */
    function vaultOf(IERC20 token) external view returns (IVault);

    /**
     * Gets the weight of the token.
     *
     * @param token to query for
     * @return weight of the token
     */
    function weightOf(IERC20 token) external view returns (Weight memory);

    /**
     * Gets the supply-position wrapper of the token.
     *
     * @param token to query for
     * @return wrapper of supply-position
     */
    function wrapperOf(IERC20 token) external view returns (IWPosition);
}

interface IPool is ISupervisedPool, IPoolRW, IPoolRO {
    /**
     * Emitted on supply.
     *
     * @param user supplying
     * @param token supplied
     * @param amount supplied
     * @param lock flag
     */
    event Supply(
        address indexed user,
        IERC20 indexed token,
        uint256 amount,
        bool lock
    );
    /**
     * Emitted on borrow.
     *
     * @param user borrowing
     * @param token borrowed
     * @param assets borrowed
     * @param lock flag
     * @param flash loan contract
     * @param data forwarded
     */
    event Borrow(
        address indexed user,
        IERC20 indexed token,
        uint256 assets,
        bool lock,
        IFlash flash,
        bytes data
    );
    /**
     * Emitted on redeem.
     *
     * @param user redeeming
     * @param token redeemed
     * @param assets redeemed
     */
    event Redeem(address indexed user, IERC20 indexed token, uint256 assets);
    /**
     * Emitted on settle.
     *
     * @param user settling
     * @param token settled
     * @param amount settled
     */
    event Settle(address indexed user, IERC20 indexed token, uint256 amount);
    /**
     * Emitted on liquidate.
     *
     * @param user liquidating
     * @param victim liquidated
     * @param partial_exp liquidated with
     */
    event Liquidate(
        address indexed user,
        address indexed victim,
        uint8 partial_exp
    );

    /** Thrown on invalid token. */
    error InvalidToken(IERC20Metadata token);
    /** Thrown on invalid tokens. */
    error InvalidTokens(IERC20Metadata[] tokens);
    /** Thrown on invalid oracle. */
    error InvalidOracle(address oracle);

    /** Thrown on not-enlisted token */
    error NotEnlisted(IERC20 token);
    /** Thrown on not-unlisted token */
    error NotUnlisted(IERC20 token);

    /** Thrown on empty supply. */
    error EmptySupply(address user, IERC20 token, uint256 amount, bool lock);
    /** Thrown on empty redeem. */
    error EmptyRedeem(address user, IERC20 token, uint256 assets);
    /** Thrown on empty borrow. */
    error EmptyBorrow(address user, IERC20 token, uint256 assets, bool lock);
    /** Thrown on empty settle. */
    error EmptySettle(address user, IERC20 token, uint256 amount);

    /** Thrown on insufficient health. */
    error InsufficientHealth(address user, uint256 supply, uint256 borrow);
    /** Thrown on sufficient health. */
    error SufficientHealth(address victim, uint256 supply, uint256 borrow);
}

interface IFlash {
    /**
     * Executes the flash-loan.
     *
     * @param token loaned
     * @param amount loaned
     * @param premium paid
     * @param initiator of the loan
     * @param data forwarded
     */
    function loan(
        IERC20 token,
        uint256 amount,
        uint256 premium,
        address initiator,
        bytes calldata data
    ) external returns (bool);
}
