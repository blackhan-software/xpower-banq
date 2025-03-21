// SPDX-License-Identifier: GPL-3.0
pragma solidity ^0.8.29;

import {IAccessManager} from "@openzeppelin/contracts/access/manager/AccessManager.sol";
import {IERC20} from "@openzeppelin/contracts/interfaces/IERC20.sol";
import {Parameterized} from "../governance/Parameterized.sol";
import {Constant} from "../../library/Constant.sol";

/**
 * @title Contract to manage pool access control
 */
abstract contract PoolSupervised is Parameterized {
    constructor(IAccessManager acma_) Parameterized(acma_) {}

    // ////////////////////////////////////////////////////////////////
    // IParameterized
    // ////////////////////////////////////////////////////////////////

    function _setTarget(
        uint256 id,
        uint256 value,
        uint256 timestamp
    ) internal override {
        uint8 lsb = _decodeLSB(id);
        if (
            lsb == max_supply_id ||
            lsb == min_supply_id ||
            lsb == max_borrow_id ||
            lsb == min_borrow_id
        ) {
            require(
                value <= Constant.YEAR,
                TooLarge({id: id, value: value, max: Constant.YEAR})
            );
            require(
                value >= Constant.SEC,
                TooSmall({id: id, value: value, min: Constant.SEC})
            );
        } else if (
            lsb == pow_supply_id || lsb == pow_borrow_id || lsb == pow_square_id
        ) {
            require(
                value <= Constant.POW,
                TooLarge({id: id, value: value, max: Constant.POW})
            );
        } else if (lsb == weight_supply_id || lsb == weight_borrow_id) {
            require(
                value <= type(uint8).max,
                TooLarge({id: id, value: value, max: type(uint8).max})
            );
        } else {
            revert Unknown(id);
        }
        super._setTarget(id, value, timestamp);
    }

    /**
     * ID of max rate-limit on supply: [1s..1y]; for given token.
     */
    function MAX_SUPPLY_ID(IERC20 token) public pure returns (uint256 id) {
        id = _idOf(abi.encodePacked(token, max_supply_id));
        id = _encodeLSB(id, max_supply_id);
    }

    /**
     * ID of min rate-limit on supply: [1s..1y]; for given token.
     */
    function MIN_SUPPLY_ID(IERC20 token) public pure returns (uint256 id) {
        id = _idOf(abi.encodePacked(token, min_supply_id));
        id = _encodeLSB(id, min_supply_id);
    }

    /**
     * ID of PoW rate-limit difficulty on supply: [0..64]; for given token.
     */
    function POW_SUPPLY_ID(IERC20 token) public pure returns (uint256 id) {
        id = _idOf(abi.encodePacked(token, pow_supply_id));
        id = _encodeLSB(id, pow_supply_id);
    }

    /**
     * ID of max rate-limit on borrow: [1s..1y]; for given token.
     */
    function MAX_BORROW_ID(IERC20 token) public pure returns (uint256 id) {
        id = _idOf(abi.encodePacked(token, max_borrow_id));
        id = _encodeLSB(id, max_borrow_id);
    }

    /**
     * ID of min rate-limit on borrow: [1s..1y]; for given token.
     */
    function MIN_BORROW_ID(IERC20 token) public pure returns (uint256 id) {
        id = _idOf(abi.encodePacked(token, min_borrow_id));
        id = _encodeLSB(id, min_borrow_id);
    }

    /**
     * ID of PoW rate-limit difficulty on borrow: [0..64]; for given token.
     */
    function POW_BORROW_ID(IERC20 token) public pure returns (uint256 id) {
        id = _idOf(abi.encodePacked(token, pow_borrow_id));
        id = _encodeLSB(id, pow_borrow_id);
    }

    /**
     * ID of PoW rate-limit difficulty on square: [0..64]; for given partial-exp.
     */
    function POW_SQUARE_ID(uint8 partial_exp) public pure returns (uint256 id) {
        id = _idOf(abi.encodePacked(partial_exp, pow_square_id));
        id = _encodeLSB(id, pow_square_id);
    }

    /**
     * ID of weight coefficient of supply: [0..255]; for given token.
     */
    function WEIGHT_SUPPLY_ID(IERC20 token) public pure returns (uint256 id) {
        id = _idOf(abi.encodePacked(token, weight_supply_id));
        id = _encodeLSB(id, weight_supply_id);
    }

    /**
     * ID of weight coefficient of borrow: [0..255]; for given token.
     */
    function WEIGHT_BORROW_ID(IERC20 token) public pure returns (uint256 id) {
        id = _idOf(abi.encodePacked(token, weight_borrow_id));
        id = _encodeLSB(id, weight_borrow_id);
    }

    uint8 private constant max_supply_id = 0x11;
    uint8 private constant min_supply_id = 0x12;
    uint8 private constant pow_supply_id = 0x14;
    uint8 private constant max_borrow_id = 0x21;
    uint8 private constant min_borrow_id = 0x22;
    uint8 private constant pow_borrow_id = 0x24;
    uint8 private constant pow_square_id = 0x44;
    uint8 private constant weight_supply_id = 0x81;
    uint8 private constant weight_borrow_id = 0x82;

    // ////////////////////////////////////////////////////////////////
    // ////////////////////////////////////////////////////////////////
}
