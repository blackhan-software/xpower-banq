// SPDX-License-Identifier: GPL-3.0
pragma solidity ^0.8.28;

library Constant {
    /** a century in [seconds] */
    uint256 internal constant CENTURY = 365_25 days;
    /** a year in [seconds] */
    uint256 internal constant YEAR = CENTURY / 100;
    /** a month [seconds] */
    uint256 internal constant MONTH = YEAR / 12;
    /** a week [seconds] */
    uint256 internal constant WEEK = 604800;
    /** a day [seconds] */
    uint256 internal constant DAY = 86400;
    /** an hour [seconds] */
    uint256 internal constant HOUR = 3600;
    /** a minute [seconds] */
    uint256 internal constant MIN = 60;
    /** a second [seconds] */
    uint256 internal constant SEC = 1;
    /** unit × 0.0 */
    uint256 internal constant NIL = 0.0e18;
    /** unit × 0.5 */
    uint256 internal constant HLF = 0.5e18;
    /** unit × 1.0 */
    uint256 internal constant ONE = 1.0e18;
    /** unit × 2.0 */
    uint256 internal constant TWO = 2.0e18;
    /** percentage */
    uint256 internal constant PCT = 1.0e16;
    /** basis points */
    uint256 internal constant BPS = 1.0e14;
    /** PoW difficulty maximum */
    uint8 internal constant POW = 64;
    /** protocol version */
    uint256 public constant VERSION = 0x1a1;
}
