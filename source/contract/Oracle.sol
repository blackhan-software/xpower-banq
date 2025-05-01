// SPDX-License-Identifier: GPL-3.0
pragma solidity ^0.8.28;

import {IAccessManager} from "@openzeppelin/contracts/access/manager/AccessManager.sol";
import {IERC20} from "@openzeppelin/contracts/interfaces/IERC20.sol";
import {Math} from "@openzeppelin/contracts/utils/math/Math.sol";

import {IOracle} from "../interface/Oracle.sol";
import {IFeed} from "../interface/Feed.sol";

import {TWAP, TWAPLib, Quote} from "../library/TWAP.sol";
import {PowLimited} from "./modifier/PowLimited.sol";
import {Constant} from "../library/Constant.sol";
import {Delayed} from "./modifier/Delayed.sol";
import {Token} from "../library/Token.sol";

import {OracleSupervised} from "./supervised/Oracle.sol";

/**
 * @title TWAP Oracle contract to provide (bid, ask) quotes
 */
abstract contract Oracle is IOracle, OracleSupervised, Delayed, PowLimited {
    using TWAPLib for TWAP;

    mapping(IERC20 t1 => mapping(IERC20 t2 => uint256)) internal _stamp;
    mapping(IERC20 t1 => mapping(IERC20 t2 => IFeed)) internal _feed;
    mapping(IERC20 t1 => mapping(IERC20 t2 => TWAP)) internal _twap;
    mapping(IERC20 t1 => uint256) internal _unit; // standard unit

    /**
     * @param decay_ factor (0.5**[1/halflife])
     * @param limit_ time of refresh (seconds)
     * @param delay_ time of enlist (seconds)
     */
    constructor(
        uint256 decay_,
        uint256 limit_,
        uint256 delay_,
        IAccessManager acma_
    ) OracleSupervised(acma_) PowLimited(1 hours) {
        _setTarget(DECAY_ID, decay_, FOR_3M);
        _setTarget(LIMIT_ID, limit_, FOR_3M);
        _setTarget(DELAY_ID, delay_, FOR_1Y);
    }

    // ////////////////////////////////////////////////////////////////
    // ISupervisedOracleRW
    // ////////////////////////////////////////////////////////////////

    function enlist(
        IERC20 source,
        IERC20 target,
        IFeed feed,
        uint256 duration
    )
        external
        override
        restricted
        delayed(
            _feed[source][target] != ZERO_FEED ? parameterOf(DELAY_ID) : 0,
            keccak256(abi.encodePacked(this.enlist.selector, source, target))
        )
    {
        _enlist(source, target, feed, duration);
    }

    function _enlist(
        IERC20 source,
        IERC20 target,
        IFeed feed,
        uint256 duration
    ) internal {
        require(source != target, InvalidPair(source, target));
        IFeed old_feed = _feed[source][target];
        // check if feed is too early
        uint256 old_dt = _durationTo(_stamp[source][target]);
        if (feed != old_feed && old_dt > 0) {
            revert TooEarlyFeed(source, target, feed, old_dt);
        }
        // check if feed is too retro
        uint256 new_dt = _timestampOf(duration);
        if (feed == old_feed && old_dt > new_dt) {
            revert TooRetroFeed(source, target, feed, old_dt);
        }
        _stamp[source][target] = _timestampOf(duration);
        _feed[source][target] = feed; // address(0) => clear
        emit Enlist(source, target, feed, duration);
    }

    event Enlist(
        IERC20 indexed source,
        IERC20 indexed target,
        IFeed feed,
        uint256 duration
    );

    // ////////////////////////////////////////////////////////////////
    // ISupervisedOracleRO
    // ////////////////////////////////////////////////////////////////

    function enlisted(
        IERC20 source,
        IERC20 target
    ) external view override returns (bool) {
        return _feed[source][target] != ZERO_FEED;
    }

    // ////////////////////////////////////////////////////////////////
    // IOracleRW
    // ////////////////////////////////////////////////////////////////

    function refresh(
        IERC20 source,
        IERC20 target
    )
        external
        override
        delayed(
            parameterOf(LIMIT_ID),
            keccak256(abi.encodePacked(this.refresh.selector, source, target))
        )
        powlimited(refreshDifficulty())
    {
        this.retwap(source, target); // if retwap-role!
    }

    function refreshDifficulty() public view override returns (uint256) {
        return parameterOf(LEVEL_ID);
    }

    function retwap(
        IERC20 source,
        IERC20 target
    )
        external
        override
        restricted
        limited(
            parameterOf(LIMIT_ID),
            keccak256(abi.encodePacked(this.retwap.selector, source, target))
        )
    {
        Quote memory quote = _quoteOf(source, target, _unitOf(source));
        TWAP memory twap = _twap[source][target];
        if (twap.last.time > 0) {
            twap = twap.update(quote, parameterOf(DECAY_ID));
        } else {
            twap = TWAPLib.init(quote);
        }
        _twap[source][target] = twap;
        emit Refresh(source, target, quote);
    }

    event Refresh(IERC20 indexed source, IERC20 indexed target, Quote quote);

    function _quoteOf(
        IERC20 source,
        IERC20 target,
        uint256 amount
    ) private view returns (Quote memory) {
        if (source != target) {
            IFeed feed = _feed[source][target];
            require(feed != IFeed(address(0)), MissingFeed(source, target));
            (uint256 bid, uint256 ask) = feed.getQuotes(amount);
            return Quote({bid: bid, ask: ask, time: block.timestamp});
        }
        return Quote({bid: amount, ask: amount, time: block.timestamp});
    }

    function _unitOf(IERC20 source) private returns (uint256) {
        uint256 unit = _unit[source];
        if (unit == 0) {
            unit = Token.unitOf(source);
            _unit[source] = unit;
        }
        return unit;
    }

    // ////////////////////////////////////////////////////////////////
    // IOracleRO
    // ////////////////////////////////////////////////////////////////

    function getFeed(
        IERC20 source,
        IERC20 target
    ) external view override returns (IFeed, uint256) {
        return (_feed[source][target], _durationTo(_stamp[source][target]));
    }

    function getQuote(
        uint256 amount,
        IERC20 source,
        IERC20 target
    ) external view override returns (uint256) {
        Quote memory quote = _twap[source][target].mean;
        require(quote.time > 0, MissingQuote(source, target));
        uint256 mid = Math.average(quote.bid, quote.ask);
        return Math.mulDiv(mid, amount, _unit[source]);
    }

    function getQuotes(
        uint256 amount,
        IERC20 source,
        IERC20 target
    ) external view override returns (uint256, uint256) {
        Quote memory quote = _twap[source][target].mean;
        require(quote.time > 0, MissingQuote(source, target));
        uint256 unit = _unit[source];
        return (
            Math.mulDiv(quote.bid, amount, unit),
            Math.mulDiv(quote.ask, amount, unit)
        );
    }

    function refreshed(
        IERC20 source,
        IERC20 target
    ) external view override returns (bool) {
        uint256 limit = parameterOf(LIMIT_ID);
        TWAP memory twap = _twap[source][target];
        return block.timestamp < twap.last.time + limit;
    }

    // ////////////////////////////////////////////////////////////////
    // const decay = (halflife: number) => 0.5 ** (1 / halflife);
    // ////////////////////////////////////////////////////////////////

    uint256 public constant DECAY_01HL = 0.500000000000000000e18;
    uint256 public constant DECAY_02HL = 0.707106781186547573e18;
    uint256 public constant DECAY_03HL = 0.793700525984099792e18;
    uint256 public constant DECAY_04HL = 0.840896415253714502e18;
    uint256 public constant DECAY_05HL = 0.870550563296124125e18;
    uint256 public constant DECAY_06HL = 0.890898718140339274e18;
    uint256 public constant DECAY_07HL = 0.905723664263906714e18;
    uint256 public constant DECAY_08HL = 0.917004043204671215e18;
    uint256 public constant DECAY_09HL = 0.925874712287290458e18;
    uint256 public constant DECAY_10HL = 0.933032991536807410e18;
    uint256 public constant DECAY_11HL = 0.938930910661706308e18;
    uint256 public constant DECAY_12HL = 0.943874312681693528e18;
    uint256 public constant DECAY_24HL = 0.971531941153605860e18;

    // ////////////////////////////////////////////////////////////////
    // ////////////////////////////////////////////////////////////////

    IFeed private constant ZERO_FEED = IFeed(address(0));
}
