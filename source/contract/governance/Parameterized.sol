// SPDX-License-Identifier: GPL-3.0
pragma solidity ^0.8.29;

import {IAccessManager} from "@openzeppelin/contracts/access/manager/AccessManager.sol";
import {Math} from "@openzeppelin/contracts/utils/math/Math.sol";

import {IParameterized} from "../../interface/governance/Parameterized.sol";
import {Integrator} from "../../library/Integrator.sol";
import {Constant} from "../../library/Constant.sol";
import {Selector} from "../../library/Selector.sol";
import {Limited} from "../modifier/Limited.sol";

import {Supervised} from "../supervised/Supervised.sol";

contract Parameterized is IParameterized, Supervised, Limited {
    using Integrator for Integrator.Item[];

    constructor(IAccessManager manager) Supervised(manager) {}

    // ////////////////////////////////////////////////////////////////
    // IParameterized
    // ////////////////////////////////////////////////////////////////

    function parameterOf(uint256 id) public view override returns (uint256) {
        return _parameter[id].meanOf(block.timestamp, _target[id]);
    }

    function getTarget(
        uint256 id
    ) external view override returns (uint256 value, uint256 dt) {
        (uint256 target, uint256 timestamp) = _getTarget(id);
        return (target, _durationTo(timestamp));
    }

    function _getTarget(
        uint256 id
    ) internal view virtual returns (uint256 value, uint256 ts) {
        return (_target[id], _target_stamp[id]);
    }

    function setTarget(
        uint256 id,
        uint256 value
    )
        external
        override
        restricted
        limited(
            Constant.MONTH,
            keccak256(abi.encodePacked(Selector.SET_TARGET, id))
        )
    {
        _setTargetIf(id, value, 0);
    }

    function setTarget(
        uint256 id,
        uint256 value,
        uint256 duration
    )
        external
        override
        restricted
        limited(
            Constant.MONTH, // *same* selector to enforce limit
            keccak256(abi.encodePacked(Selector.SET_TARGET, id))
        )
    {
        _setTargetIf(id, value, _timestampOf(duration));
    }

    function _setTargetIf(
        uint256 id,
        uint256 value,
        uint256 timestamp
    ) private {
        uint256 old_value = _target[id];
        uint256 dbl_value = old_value << 1;
        if (value > dbl_value && old_value > 0) {
            revert TooLarge(id, value, dbl_value);
        }
        uint256 hlf_value = old_value >> 1;
        if (value < hlf_value) {
            revert TooSmall(id, value, hlf_value);
        }
        uint256 old_dt = _durationTo(_target_stamp[id]);
        if (value != old_value && old_dt > 0) {
            revert TooEarly(id, value, old_dt);
        }
        uint256 new_dt = _durationTo(timestamp);
        if (value == old_value && old_dt > new_dt) {
            revert TooRetro(id, value, old_dt);
        }
        _setTarget(id, value, timestamp);
    }

    function _setTarget(
        uint256 id,
        uint256 value,
        uint256 timestamp
    ) internal virtual {
        if (_parameter[id].length > 0) {
            _parameter[id].append(block.timestamp, _target[id]);
        } else {
            _parameter[id].append(block.timestamp, value);
        }
        (_target[id], _target_stamp[id]) = (value, timestamp);
        emit Target(id, value, _durationTo(timestamp));
    }

    /** Gets the duration to the given timestamp. */
    function _durationTo(uint256 timestamp) internal view returns (uint256 dt) {
        if (timestamp > block.timestamp) {
            return timestamp - block.timestamp;
        }
        return 0;
    }

    /** Gets the timestamp of the given duration. */
    function _timestampOf(uint256 duration) internal view returns (uint256 ts) {
        (bool ok, uint256 timestamp) = Math.tryAdd(block.timestamp, duration);
        if (!ok) return type(uint256).max;
        return timestamp;
    }

    /** Encodes least-significant byte into id. */
    function _encodeLSB(uint256 id, uint8 lsb) internal pure returns (uint256) {
        return (id - uint8(id)) | lsb;
    }

    /** Decodes least-significant byte from id. */
    function _decodeLSB(uint256 id) internal pure returns (uint8 lsb) {
        return uint8(id);
    }

    /** Gets the identifier of the given data. */
    function _idOf(bytes memory data) internal pure returns (uint256) {
        return uint256(keccak256(data));
    }

    mapping(uint256 id => Integrator.Item[]) private _parameter;
    mapping(uint256 id => uint256 value) private _target_stamp;
    mapping(uint256 id => uint256 value) private _target;

    /** Timestamp in 3 months (w.r.t. contract instantiation). */
    uint256 immutable FOR_3M = _timestampOf(Constant.MONTH * 3);
    /** Timestamp in 1 year (w.r.t. contract instantiation). */
    uint256 immutable FOR_1Y = _timestampOf(Constant.YEAR);

    // ////////////////////////////////////////////////////////////////
    // ////////////////////////////////////////////////////////////////
}
