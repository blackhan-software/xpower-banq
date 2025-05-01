// SPDX-License-Identifier: GPL-3.0
pragma solidity ^0.8.28;

import {IAccessManaged} from "@openzeppelin/contracts/access/manager/AccessManager.sol";
import {IERC20Metadata} from "@openzeppelin/contracts/interfaces/IERC20Metadata.sol";
import {IERC20} from "@openzeppelin/contracts/interfaces/IERC20.sol";
import {ERC20} from "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import {Test} from "forge-std/Test.sol";

import {Constant} from "../../source/library/Constant.sol";
import {IRModel} from "../../source/struct/IRModel.sol";
import {VaultFee} from "../../source/struct/VaultFee.sol";
import {Health} from "../../source/struct/Health.sol";
import {Weight} from "../../source/struct/Weight.sol";

import {ISupplyPosition} from "../../source/interface/Position.sol";
import {IBorrowPosition} from "../../source/interface/Position.sol";
import {IWPosition} from "../../source/interface/WPosition.sol";
import {IOracle} from "../../source/interface/Oracle.sol";
import {IVault} from "../../source/interface/Vault.sol";
import {IPoolRO} from "../../source/interface/Pool.sol";
import {IAcma} from "../../source/interface/Acma.sol";

import {SupplyPosition} from "../../source/contract/Position.sol";
import {BorrowPosition} from "../../source/contract/Position.sol";
import {Vault} from "../../source/contract/Vault.sol";
import {Acma} from "../../source/contract/Acma.sol";

contract BaseTest is Test, IPoolRO {
    address immutable self = address(this);
    address immutable papa = address(0xbaba);

    uint256 constant MONTH = Constant.MONTH;
    uint256 constant ONE = Constant.ONE;
    uint256 constant PCT = Constant.PCT;
    uint256 constant BPS = Constant.BPS;

    IERC20Metadata internal immutable token = new ABCToken(100 * ONE);
    IERC20Metadata internal immutable buddy = new XYZToken(100 * ONE);
    SupplyPosition internal immutable supply;
    BorrowPosition internal immutable borrow;
    IVault internal immutable vault;
    IAcma internal immutable acma;

    VaultFee VAULT_NIL =
        VaultFee({
            entry: 0,
            entryRecipient: address(0),
            exit: 0,
            exitRecipient: address(0)
        });

    IRModel IR_MODEL =
        IRModel({util: 90 * PCT, rate: 10 * PCT, spread: 0 * PCT});

    constructor(VaultFee memory fee_, IRModel memory irm_) {
        acma = new Acma(address(this));
        supply = new SupplyPosition(this, token, buddy, irm_, acma);
        borrow = new BorrowPosition(this, token, buddy, irm_, acma);
        vault = new Vault(address(this), token, fee_, supply, borrow, acma);
    }

    bytes4 immutable AM_UNAUTHORIZED =
        IAccessManaged.AccessManagedUnauthorized.selector;

    // ////////////////////////////////////////////////////////////////
    // IPoolRO
    // ////////////////////////////////////////////////////////////////

    function oracle() external pure override returns (IOracle) {
        revert("BaseTest: not implemented");
    }

    function tokens() external view override returns (IERC20Metadata[] memory) {
        IERC20Metadata[] memory array = new IERC20Metadata[](1);
        array[0] = token;
        return array;
    }

    function healthOf(address) external view override returns (Health memory) {
        return _health;
    }

    function supplyOf(IERC20) external view override returns (ISupplyPosition) {
        return supply;
    }

    function borrowOf(IERC20) external view override returns (IBorrowPosition) {
        return borrow;
    }

    function supplyLockOf(
        address user,
        IERC20
    ) external view override returns (uint256) {
        return supply.lockOf(user);
    }

    function borrowLockOf(
        address user,
        IERC20
    ) external view override returns (uint256) {
        return borrow.lockOf(user);
    }

    function supplyDifficultyOf(
        IERC20,
        uint256
    ) external pure override returns (uint256) {
        return 0;
    }

    function borrowDifficultyOf(
        IERC20,
        uint256
    ) external pure override returns (uint256) {
        return 0;
    }

    function liquidateDifficultyOf(
        uint8
    ) external pure override returns (uint256) {
        return 0;
    }

    function vaultOf(IERC20) external view override returns (IVault) {
        return vault;
    }

    function weightOf(IERC20) external pure override returns (Weight memory) {
        return Weight({supply: 255, borrow: 255});
    }

    function wrapperOf(IERC20) external pure override returns (IWPosition) {
        revert("BaseTest: not implemented");
    }

    function _setHealth(Health memory health) internal {
        _health = health;
    }

    Health internal _health;
}

contract ABCToken is ERC20 {
    constructor(uint256 amount) ERC20("ABCToken", "ABC") {
        _mint(msg.sender, amount);
    }
}

contract XYZToken is ERC20 {
    constructor(uint256 amount) ERC20("XYZToken", "XYZ") {
        _mint(msg.sender, amount);
    }
}
