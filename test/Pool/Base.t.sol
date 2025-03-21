// SPDX-License-Identifier: GPL-3.0
pragma solidity ^0.8.29;

import {IAccessManaged} from "@openzeppelin/contracts/access/manager/AccessManager.sol";
import {IERC20Metadata} from "@openzeppelin/contracts/interfaces/IERC20Metadata.sol";
import {ERC20} from "@openzeppelin/contracts/token/ERC20/ERC20.sol";

import {IOracle} from "../../source/interface/Oracle.sol";
import {IVault} from "../../source/interface/Vault.sol";
import {IAcma} from "../../source/interface/Acma.sol";

import {VaultMill} from "../../source/library/mill/Vault.sol";
import {Constant} from "../../source/library/Constant.sol";
import {Roles} from "../../source/library/Roles.sol";

import {RateLimit} from "../../source/struct/RateLimit.sol";
import {IRModel} from "../../source/struct/IRModel.sol";
import {VaultFee} from "../../source/struct/VaultFee.sol";
import {Weight} from "../../source/struct/Weight.sol";

import {WPosition} from "../../source/contract/WPosition.sol";
import {PoolInit} from "../../script/library/PoolInit.sol";
import {Pool} from "../../source/contract/Pool.sol";
import {Acma} from "../../source/contract/Acma.sol";

import {RWMockOracle} from "../../test/Oracle/MockOracle.rw.sol";
import {Test} from "forge-std/Test.sol";

contract BaseTest is Test {
    uint256 constant MONTH = Constant.MONTH;
    uint256 constant ONE = Constant.ONE;
    uint256 constant PCT = Constant.PCT;
    uint256 constant BPS = Constant.BPS;

    IERC20Metadata immutable AVAX;
    uint256 immutable AVAX_ONE; // 1e18
    IERC20Metadata immutable USDC;
    uint256 immutable USDC_ONE; // 1e6

    IERC20Metadata[] internal tokens;
    IERC20Metadata[] internal TOKENS = [
        new Token(1000, "AVAX", 18),
        new Token(1000, "USDC", 6)
    ];

    Weight WEIGHT = Weight({borrow: 255, supply: 170});
    RateLimit RATE_LIMIT = RateLimit({max: 7 days, min: 1 days});
    IRModel IR_MODEL =
        IRModel({util: 90 * PCT, rate: 10 * PCT, spread: 0 * PCT});

    VaultFee VAULT_FEE =
        VaultFee({
            entry: 10 * BPS,
            entryRecipient: address(0),
            exit: 10 * BPS,
            exitRecipient: address(0)
        });

    VaultFee VAULT_NIL =
        VaultFee({
            entry: 0,
            entryRecipient: address(0),
            exit: 0,
            exitRecipient: address(0)
        });

    IVault internal immutable VAULT0 = IVault(address(0));
    RWMockOracle immutable DELPHI = new RWMockOracle();
    IOracle internal immutable oracle;
    IAcma internal immutable acma;
    Pool internal immutable pool;

    constructor(
        IERC20Metadata[] memory tokens_,
        VaultFee memory fee_,
        IRModel memory model_,
        IOracle oracle_
    ) {
        AVAX = TOKENS[0];
        AVAX_ONE = 10 ** AVAX.decimals();
        USDC = TOKENS[1];
        USDC_ONE = 10 ** USDC.decimals();
        tokens = tokens_;
        oracle = oracle_;
        acma = new Acma(self);
        pool = new Pool(tokens, oracle, acma);
        IVault vault0 = VaultMill.vault(pool, 0, model_, fee_, acma);
        IVault vault1 = VaultMill.vault(pool, 1, model_, fee_, acma);
        pool.enlist(0, vault0, WEIGHT, RATE_LIMIT);
        pool.enlist(1, vault1, WEIGHT, RATE_LIMIT);
        pool.enwrap(0, new WPosition(pool.supplyOf(tokens[0])));
        pool.enwrap(1, new WPosition(pool.supplyOf(tokens[1])));
        acma.grantRole(acma.ACMA_RELATE_ROLE(), self, 0);
        PoolInit.enroll(pool, acma);
        acma.revokeRole(acma.ACMA_RELATE_ROLE(), self);
    }

    address constant zero = address(0x0000);
    address constant papa = address(0xbaba);
    address constant caca = address(0xcaca);
    address constant dada = address(0xdada);
    address immutable self = address(this);
    Token T18 = new Token(ONE, "T18", 18);

    bytes4 immutable AM_UNAUTHORIZED =
        IAccessManaged.AccessManagedUnauthorized.selector;
}

contract Token is ERC20 {
    constructor(
        uint256 supply_,
        string memory symbol_,
        uint8 decimals_
    ) ERC20("Token", symbol_) {
        _decimals = decimals_;
        _mint(msg.sender, supply_ * 10 ** decimals());
    }

    function decimals() public view override returns (uint8) {
        return _decimals;
    }

    uint8 private immutable _decimals;
}
