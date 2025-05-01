// SPDX-License-Identifier: GPL-3.0
pragma solidity ^0.8.28;

import {IAccessManager} from "@openzeppelin/contracts/access/manager/AccessManager.sol";
import {AccessManaged} from "@openzeppelin/contracts/access/manager/AccessManaged.sol";
import {Constant} from "../../library/Constant.sol";

/**
 * @title Contract to manage access control
 */
abstract contract Supervised is AccessManaged {
    /** protocol version */
    uint256 public constant VERSION = Constant.VERSION;

    /**
     * @param acma_ access manager
     */
    constructor(IAccessManager acma_) AccessManaged(address(acma_)) {}
}
