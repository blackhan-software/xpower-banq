// SPDX-License-Identifier: GPL-3.0
pragma solidity ^0.8.29;

import {Strings} from "@openzeppelin/contracts/utils/Strings.sol";

library String {
    /**
     * Compares two strings for equality.
     *
     * @param lhs the first string
     * @param rhs the second string
     * @return true if the strings are equal, false otherwise
     */
    function eq(
        string memory lhs,
        string memory rhs
    ) internal pure returns (bool) {
        return keccak256(bytes(lhs)) == keccak256(bytes(rhs));
    }

    /**
     * Concatenates two strings.
     *
     * @param a the first string
     * @param b the second string
     * @return joined the concatenation of a and b
     */
    function join(
        string memory a,
        string memory b
    ) internal pure returns (string memory joined) {
        return string(abi.encodePacked(a, b));
    }

    /**
     * Concatenates a number and a string.
     *
     * @param n the number
     * @param a the string
     * @return joined the concatenation of n and a
     */
    function join(
        uint256 n,
        string memory a
    ) internal pure returns (string memory joined) {
        return string(abi.encodePacked(Strings.toString(n), a));
    }

    /**
     * Concatenates a string and a number.
     *
     * @param a the string
     * @param n the number
     * @return joined the concatenation of a and n
     */
    function join(
        string memory a,
        uint256 n
    ) internal pure returns (string memory joined) {
        return string(abi.encodePacked(a, Strings.toString(n)));
    }

    /**
     * Concatenates a number and two strings.
     *
     * @param n the number
     * @param a the first string
     * @param b the second string
     * @return joined the concatenation of n, a and b
     */
    function join(
        uint256 n,
        string memory a,
        string memory b
    ) internal pure returns (string memory joined) {
        return string(abi.encodePacked(Strings.toString(n), a, b));
    }

    /**
     * Concatenates two strings and a number.
     *
     * @param a the first string
     * @param n the number
     * @param b the second string
     * @return joined the concatenation of a, n and b
     */
    function join(
        string memory a,
        uint256 n,
        string memory b
    ) internal pure returns (string memory joined) {
        return string(abi.encodePacked(a, Strings.toString(n), b));
    }

    /**
     * Concatenates a number and two strings.
     *
     * @param a the first string
     * @param b the second string
     * @param n the number
     * @return joined the concatenation of a, b and n
     */
    function join(
        string memory a,
        string memory b,
        uint256 n
    ) internal pure returns (string memory joined) {
        return string(abi.encodePacked(a, b, Strings.toString(n)));
    }

    /**
     * Concatenates three strings.
     *
     * @param a the first string
     * @param b the second string
     * @param c the third string
     * @return joined the concatenation of a, b and c
     */
    function join(
        string memory a,
        string memory b,
        string memory c
    ) internal pure returns (string memory joined) {
        return string(abi.encodePacked(a, b, c));
    }

    /**
     * Concatenates three strings.
     *
     * @param a the first string
     * @param b the second string
     * @param c the third string
     * @param d the fourth string
     * @return joined the concatenation of a, b and c
     */
    function join(
        string memory a,
        string memory b,
        string memory c,
        string memory d
    ) internal pure returns (string memory joined) {
        return string(abi.encodePacked(a, b, c, d));
    }
}
