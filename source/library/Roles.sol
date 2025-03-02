// SPDX-License-Identifier: GPL-3.0
pragma solidity ^0.8.28;

library Roles {
    function SET_TARGET(string memory s) internal pure returns (uint64) {
        return role_id("SET_TARGET", s);
    }
    function SET_TARGET_ADMIN(string memory s) internal pure returns (uint64) {
        return role_id("SET_TARGET_ADMIN", s);
    }
    function CAP_SUPPLY(string memory s) internal pure returns (uint64) {
        return role_id("CAP_SUPPLY", s);
    }
    function CAP_SUPPLY_ADMIN(string memory s) internal pure returns (uint64) {
        return role_id("CAP_SUPPLY_ADMIN", s);
    }
    function CAP_BORROW(string memory s) internal pure returns (uint64) {
        return role_id("CAP_BORROW", s);
    }
    function CAP_BORROW_ADMIN(string memory s) internal pure returns (uint64) {
        return role_id("CAP_BORROW_ADMIN", s);
    }
    function TMP_SUPPLY(string memory s) internal pure returns (uint64) {
        return role_id("TMP_SUPPLY", s);
    }
    function TMP_SUPPLY_ADMIN(string memory s) internal pure returns (uint64) {
        return role_id("TMP_SUPPLY_ADMIN", s);
    }
    function TMP_BORROW(string memory s) internal pure returns (uint64) {
        return role_id("TMP_BORROW", s);
    }
    function TMP_BORROW_ADMIN(string memory s) internal pure returns (uint64) {
        return role_id("TMP_BORROW_ADMIN", s);
    }
    function ENLIST(string memory s) internal pure returns (uint64) {
        return role_id("ENLIST", s);
    }
    function ENLIST_ADMIN(string memory s) internal pure returns (uint64) {
        return role_id("ENLIST_ADMIN", s);
    }
    function ENWRAP(string memory s) internal pure returns (uint64) {
        return role_id("ENWRAP", s);
    }
    function ENWRAP_ADMIN(string memory s) internal pure returns (uint64) {
        return role_id("ENWRAP_ADMIN", s);
    }
    function RETWAP(string memory s) internal pure returns (uint64) {
        return role_id("RETWAP", s);
    }
    function RETWAP_ADMIN(string memory s) internal pure returns (uint64) {
        return role_id("RETWAP_ADMIN", s);
    }
    function SQUARE(string memory s) internal pure returns (uint64) {
        return role_id("SQUARE", s);
    }
    function SQUARE_ADMIN(string memory s) internal pure returns (uint64) {
        return role_id("SQUARE_ADMIN", s);
    }
    function RELATE(string memory s) internal pure returns (uint64) {
        return role_id("RELATE", s);
    }
    function RELATE_ADMIN(string memory s) internal pure returns (uint64) {
        return role_id("RELATE_ADMIN", s);
    }
    function role_id(
        string memory s1,
        string memory s2
    ) private pure returns (uint64) {
        return uint64(bytes8(keccak256(abi.encodePacked(s1, s2))));
    }
}
