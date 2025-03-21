// SPDX-License-Identifier: GPL-3.0
pragma solidity ^0.8.29;

library Selector {
    bytes4 internal constant CAP_SUPPLY =
        bytes4(keccak256("capSupply(address,uint256)"));
    bytes4 internal constant TMP_SUPPLY =
        bytes4(keccak256("capSupply(address,uint256,uint256)"));
    bytes4 internal constant CAP_BORROW =
        bytes4(keccak256("capBorrow(address,uint256)"));
    bytes4 internal constant TMP_BORROW =
        bytes4(keccak256("capBorrow(address,uint256,uint256)"));
    bytes4 internal constant SET_TARGET =
        bytes4(keccak256("setTarget(uint256,uint256)"));
    bytes4 internal constant TMP_TARGET =
        bytes4(keccak256("setTarget(uint256,uint256,uint256)"));
}
