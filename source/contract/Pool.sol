// SPDX-License-Identifier: GPL-3.0
pragma solidity ^0.8.29;

import {ReentrancyGuardTransient} from "@openzeppelin/contracts/utils/ReentrancyGuardTransient.sol";
import {IAccessManaged} from "@openzeppelin/contracts/access/manager/AccessManaged.sol";
import {IAccessManager} from "@openzeppelin/contracts/access/manager/AccessManager.sol";
import {IERC20Metadata} from "@openzeppelin/contracts/interfaces/IERC20Metadata.sol";
import {SafeERC20} from "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";
import {IERC20} from "@openzeppelin/contracts/interfaces/IERC20.sol";
import {Math} from "@openzeppelin/contracts/utils/math/Math.sol";

import {ISupplyPosition} from "../interface/Position.sol";
import {IBorrowPosition} from "../interface/Position.sol";
import {IWPosition} from "../interface/WPosition.sol";
import {IPool, IFlash} from "../interface/Pool.sol";
import {IOracle} from "../interface/Oracle.sol";
import {IVault} from "../interface/Vault.sol";

import {RateLimited} from "./modifier/RateLimited.sol";
import {PowLimited} from "./modifier/PowLimited.sol";
import {Constant} from "../library/Constant.sol";
import {Oracle} from "../library/Oracle.sol";
import {Token} from "../library/Token.sol";
import {Array} from "../library/Array.sol";

import {PoolSupervised} from "./supervised/Pool.sol";
import {RateLimit} from "../struct/RateLimit.sol";
import {Health} from "../struct/Health.sol";
import {Weight} from "../struct/Weight.sol";
import {Listed} from "../enum/Listed.sol";

/**
 * @title Pool contract for lending and borrowing
 */
contract Pool is
    ReentrancyGuardTransient,
    PoolSupervised,
    RateLimited,
    PowLimited,
    IPool
{
    using SafeERC20 for IERC20;
    using Array for uint256[];
    using Oracle for IOracle;

    IERC20Metadata[] private _tokens;
    IOracle private immutable _oracle;
    mapping(IERC20 t => IVault) private _vault;
    mapping(IERC20 t => Listed) private _listed;

    constructor(
        IERC20Metadata[] memory tokens_,
        IOracle oracle_,
        IAccessManager acma_
    ) PoolSupervised(acma_) PowLimited(1 hours) {
        require(tokens_.length >= 2, InvalidTokens(tokens_));
        require(tokens_[0].decimals() >= 6, InvalidToken(tokens_[0]));
        require(tokens_[1].decimals() >= 6, InvalidToken(tokens_[1]));
        require(address(oracle_) != address(0), InvalidOracle(address(0)));
        _tokens = tokens_;
        _oracle = oracle_;
    }

    // ////////////////////////////////////////////////////////////////
    // ISupervisedPoolCap
    // ////////////////////////////////////////////////////////////////

    function capSupplyOf(
        address user,
        IERC20 token
    ) external view override returns (uint256 limit, uint256 dt) {
        require(enlisted(token), NotEnlisted(token));
        (limit, dt) = _supplyOf(token).capOf(user);
    }

    function capSupply(
        IERC20 token
    ) external view override returns (uint256 limit, uint256 dt) {
        require(enlisted(token), NotEnlisted(token));
        (limit, dt) = _supplyOf(token).cap();
    }

    function capSupply(
        IERC20 token,
        uint256 limit
    ) external override restricted {
        require(enlisted(token), NotEnlisted(token));
        _capSupply(token, limit, 0);
    }

    function capSupply(
        IERC20 token,
        uint256 limit,
        uint256 dt
    ) external override restricted {
        require(enlisted(token), NotEnlisted(token));
        _capSupply(token, limit, dt);
    }

    function _capSupply(IERC20 token, uint256 limit, uint256 dt) private {
        emit CapSupply(token, limit, dt);
        _supplyOf(token).cap(limit, dt);
    }

    function capBorrowOf(
        address user,
        IERC20 token
    ) external view override returns (uint256 limit, uint256 dt) {
        require(enlisted(token), NotEnlisted(token));
        (limit, dt) = _borrowOf(token).capOf(user);
    }

    function capBorrow(
        IERC20 token
    ) external view override returns (uint256 limit, uint256 dt) {
        require(enlisted(token), NotEnlisted(token));
        (limit, dt) = _borrowOf(token).cap();
    }

    function capBorrow(
        IERC20 token,
        uint256 limit
    ) external override restricted {
        require(enlisted(token), NotEnlisted(token));
        _capBorrow(token, limit, 0);
    }

    function capBorrow(
        IERC20 token,
        uint256 limit,
        uint256 dt
    ) external override restricted {
        require(enlisted(token), NotEnlisted(token));
        _capBorrow(token, limit, dt);
    }

    function _capBorrow(IERC20 token, uint256 limit, uint256 dt) private {
        emit CapBorrow(token, limit, dt);
        _borrowOf(token).cap(limit, dt);
    }

    event CapSupply(IERC20 indexed token, uint256 limit, uint256 dt);
    event CapBorrow(IERC20 indexed token, uint256 limit, uint256 dt);

    // ////////////////////////////////////////////////////////////////
    // ISupervisedPoolRW
    // ////////////////////////////////////////////////////////////////

    function enlist(
        uint256 index,
        IVault vault,
        Weight memory weight,
        RateLimit memory rate_limit
    ) external override restricted {
        IERC20Metadata token = _tokens[index];
        require(unlisted(token), NotUnlisted(token));
        _setTarget(WEIGHT_SUPPLY_ID(token), weight.supply, FOR_3M);
        _setTarget(WEIGHT_BORROW_ID(token), weight.borrow, FOR_3M);
        _setTarget(MAX_SUPPLY_ID(token), rate_limit.max, FOR_1Y);
        _setTarget(MIN_SUPPLY_ID(token), rate_limit.min, FOR_1Y);
        _setTarget(MAX_BORROW_ID(token), rate_limit.max, FOR_1Y);
        _setTarget(MIN_BORROW_ID(token), rate_limit.min, FOR_1Y);
        _listed[token] = Listed.enlisted;
        _vault[token] = vault;
        emit Enlist(token);
    }

    function enwrap(
        uint256 index,
        IWPosition wposition
    ) external override restricted {
        IERC20Metadata token = _tokens[index];
        require(enlisted(token), NotEnlisted(token));
        if (_wrapper[token] == IWPosition(address(0))) {
            _wrapper[token] = wposition;
            emit Enwrap(token);
        }
    }

    // ////////////////////////////////////////////////////////////////
    // ISupervisedPoolRO
    // ////////////////////////////////////////////////////////////////

    function enlisted(IERC20 token) public view override returns (bool) {
        return _listed[token] == Listed.enlisted;
    }

    function unlisted(IERC20 token) public view override returns (bool) {
        return _listed[token] == Listed.unlisted;
    }

    // ////////////////////////////////////////////////////////////////
    // IPoolRW: supply
    // ////////////////////////////////////////////////////////////////

    function supply(
        IERC20 token,
        uint256 amount
    ) external override returns (uint256 assets) {
        assets = supply(token, amount, false);
    }

    function supply(
        IERC20 token,
        uint256 amount,
        bool lock
    )
        public
        override
        nonReentrant
        ratelimited(
            parameterOf(MAX_SUPPLY_ID(token)),
            parameterOf(MIN_SUPPLY_ID(token)),
            keccak256(abi.encodePacked(bytes4(0x7cf51195), tx.origin, token))
        )
        powlimited(supplyDifficultyOf(token, amount))
        returns (uint256 assets)
    {
        require(enlisted(token), NotEnlisted(token));
        assets = _supply(msg.sender, token, amount, lock);
        emit Supply(msg.sender, token, amount, lock);
    }

    function supplyDifficultyOf(
        IERC20 token,
        uint256 amount
    ) public view override returns (uint256) {
        uint256 difficulty = parameterOf(POW_SUPPLY_ID(token));
        uint256 decimals = Token.decimalsOf(token);
        if (amount < 10 ** decimals) {
            uint256 log10 = Math.log10(amount);
            if (decimals > log10) {
                unchecked {
                    difficulty += decimals - log10;
                }
            }
        }
        return difficulty;
    }

    function _supply(
        address user,
        IERC20 token,
        uint256 amount,
        bool lock
    ) private returns (uint256 assets) {
        IVault vault = _vault[token];
        // token: user => vault (via pool)
        token.safeTransferFrom(user, address(this), amount);
        assert(token.approve(address(vault), amount));
        uint256 shares = vault.deposit(amount, address(this));
        // supply: zero => user
        assets = vault.convertToAssets(shares);
        vault.supply().mint(user, assets, lock);
        require(assets > 0, EmptySupply(user, token, amount, lock));
    }

    // ////////////////////////////////////////////////////////////////
    // IPoolRW: redeem
    // ////////////////////////////////////////////////////////////////

    function redeem(
        IERC20 token,
        uint256 assets
    ) external override nonReentrant returns (uint256 amount) {
        require(enlisted(token), NotEnlisted(token));
        amount = _redeem(msg.sender, token, assets);
        _checkHealth(msg.sender);
        emit Redeem(msg.sender, token, assets);
    }

    function _redeem(
        address user,
        IERC20 token,
        uint256 assets
    ) private returns (uint256 amount) {
        IVault vault = _vault[token];
        // supply: user => zero w/o unlock
        vault.supply().burn(user, assets, false);
        // token: vault => user
        uint256 shares = vault.convertToShares(assets);
        amount = vault.redeem(shares, user, address(this));
        require(amount > 0, EmptyRedeem(user, token, assets));
    }

    // ////////////////////////////////////////////////////////////////
    // IPoolRW, IFlashPoolRW: borrow
    // ////////////////////////////////////////////////////////////////

    function borrow(
        IERC20 token,
        uint256 assets
    ) external override returns (uint256 amount) {
        amount = borrow(token, assets, false, IFlash(address(0)), "");
    }

    function borrow(
        IERC20 token,
        uint256 assets,
        bool lock
    ) external override returns (uint256 amount) {
        amount = borrow(token, assets, lock, IFlash(address(0)), "");
    }

    function borrow(
        IERC20 token,
        uint256 assets,
        bool lock,
        IFlash flash,
        bytes memory data
    )
        public
        override
        nonReentrant
        ratelimited(
            parameterOf(MAX_BORROW_ID(token)),
            parameterOf(MIN_BORROW_ID(token)),
            keccak256(abi.encodePacked(bytes4(0x696a1504), tx.origin, token))
        )
        powlimited(borrowDifficultyOf(token, assets))
        returns (uint256 amount)
    {
        require(enlisted(token), NotEnlisted(token));
        amount = _borrow(msg.sender, token, assets, lock, flash, data);
        _checkHealth(msg.sender);
        emit Borrow(msg.sender, token, assets, lock, flash, data);
    }

    function borrowDifficultyOf(
        IERC20 token,
        uint256 amount
    ) public view override returns (uint256) {
        uint256 difficulty = parameterOf(POW_BORROW_ID(token));
        uint256 decimals = Token.decimalsOf(token);
        if (amount < 10 ** decimals) {
            uint256 log10 = Math.log10(amount);
            if (decimals > log10) {
                unchecked {
                    difficulty += decimals - log10;
                }
            }
        }
        return difficulty;
    }

    function _borrow(
        address user,
        IERC20 token,
        uint256 assets,
        bool lock,
        IFlash flash,
        bytes memory data
    ) private returns (uint256 amount) {
        IVault vault = _vault[token];
        // borrow: zero => user
        vault.borrow().mint(user, assets, lock);
        // token: vault => user
        uint256 shares = vault.convertToShares(assets);
        amount = vault.redeem(shares, user, address(this));
        // flash-loan:
        if (address(flash) != address(0)) {
            uint256 fee = assets - amount; // assets >= amount
            assert(flash.loan(token, amount, fee, user, data));
            _settle(user, token, assets);
        }
        require(amount > 0, EmptyBorrow(user, token, assets, lock));
    }

    // ////////////////////////////////////////////////////////////////
    // IPoolRW: settle
    // ////////////////////////////////////////////////////////////////

    function settle(
        IERC20 token,
        uint256 amount
    ) external override nonReentrant returns (uint256 assets) {
        require(enlisted(token), NotEnlisted(token));
        assets = _settle(msg.sender, token, amount);
        emit Settle(msg.sender, token, amount);
    }

    function _settle(
        address user,
        IERC20 token,
        uint256 amount
    ) private returns (uint256 assets) {
        IVault vault = _vault[token];
        // token: user => vault (via pool)
        token.safeTransferFrom(user, address(this), amount);
        assert(token.approve(address(vault), amount));
        uint256 shares = vault.deposit(amount, address(this));
        assets = vault.convertToAssets(shares);
        // borrow: user => zero w/o unlock
        vault.borrow().burn(user, amount, false);
        require(assets > 0, EmptySettle(user, token, amount));
    }

    // ////////////////////////////////////////////////////////////////
    // IPoolRW: liquidate
    // ////////////////////////////////////////////////////////////////

    function liquidate(
        address victim,
        uint8 partial_exp
    ) external override powlimited(liquidateDifficultyOf(partial_exp)) {
        this.square(msg.sender, victim, partial_exp); // if square-role!
    }

    function liquidateDifficultyOf(
        uint8 partial_exp
    ) public view override returns (uint256) {
        return parameterOf(POW_SQUARE_ID(partial_exp));
    }

    function square(
        address user,
        address victim,
        uint8 partial_exp
    ) external override nonReentrant restricted {
        Health memory h = _healthOf(victim);
        if (h.wnav_supply >= h.wnav_borrow) {
            revert SufficientHealth(victim, h.wnav_supply, h.wnav_borrow);
        }
        _square(user, victim, partial_exp);
        emit Liquidate(user, victim, partial_exp);
    }

    // slither-disable-next-line reentrancy-no-eth
    function _square(address user, address victim, uint8 partial_exp) private {
        require(
            msg.sender == user || msg.sender == address(this),
            IAccessManaged.AccessManagedUnauthorized(msg.sender)
        );
        for (uint256 i = 0; i < _tokens.length; i++) {
            IERC20 t = _tokens[i];
            IVault v = _vault[t];
            // *partially* settle victim's borrow
            IBorrowPosition bp = v.borrow();
            uint256 total = bp.totalOf(victim);
            if (total > 0) {
                uint256 borrowed = total >> partial_exp;
                if (borrowed == 0) continue; // ignore dust
                // slither-disable-next-line arbitrary-send-erc20
                t.safeTransferFrom(user, address(this), borrowed);
                assert(t.approve(address(v), borrowed));
                assert(v.deposit(borrowed, address(this)) > 0);
                bp.burn(victim, borrowed, true); // unlock
            }
        }
        for (uint256 i = 0; i < _tokens.length; i++) {
            IERC20 t = _tokens[i];
            IVault v = _vault[t];
            // *partially* seize victim's supply
            ISupplyPosition sp = v.supply();
            uint256 total = sp.totalOf(victim);
            if (total > 0) {
                uint256 supplied = total >> partial_exp;
                if (supplied == 0) continue; // ignore dust
                // slither-disable-next-line arbitrary-send-erc20
                assert(sp.transferFrom(victim, user, supplied));
            }
        }
    }

    function _checkHealth(address user) private view {
        Health memory h = _healthOf(user);
        if (h.wnav_supply < h.wnav_borrow) {
            revert InsufficientHealth(user, h.wnav_supply, h.wnav_borrow);
        }
    }

    // ////////////////////////////////////////////////////////////////
    // IPoolRO
    // ////////////////////////////////////////////////////////////////

    function oracle() external view override returns (IOracle) {
        return _oracle;
    }

    function tokens() external view returns (IERC20Metadata[] memory) {
        return _tokens;
    }

    function healthOf(address user) external view returns (Health memory) {
        return _healthOf(user);
    }

    function _healthOf(address user) private view returns (Health memory) {
        uint256 n_tokens = _tokens.length; // pre-registered tokens
        uint256[] memory wnav_supply = new uint256[](n_tokens);
        uint256[] memory wnav_borrow = new uint256[](n_tokens);
        IERC20 target = _tokens[0]; // reference token != 0x0
        for (uint256 i = 0; i < n_tokens; i++) {
            IERC20 source = _tokens[i];
            // [n]et [a]sset [v]alue of supply
            uint256 nav_supply = _oracle.minQuote(
                _supplyOf(source).totalOf(user),
                source,
                target
            );
            // [n]et [a]sset [v]alue of borrow
            uint256 nav_borrow = _oracle.maxQuote(
                _borrowOf(source).totalOf(user),
                source,
                target
            );
            Weight memory weight = _weightOf(source);
            wnav_supply[i] = weight.supply * nav_supply;
            wnav_borrow[i] = weight.borrow * nav_borrow;
        }
        return
            Health({
                wnav_supply: wnav_supply.mean(),
                wnav_borrow: wnav_borrow.mean()
            });
    }

    function supplyOf(
        IERC20 token
    ) external view override returns (ISupplyPosition) {
        require(enlisted(token), NotEnlisted(token));
        return _supplyOf(token);
    }

    function supplyLockOf(
        address user,
        IERC20 token
    ) external view override returns (uint256) {
        require(enlisted(token), NotEnlisted(token));
        return _supplyOf(token).lockOf(user);
    }

    function _supplyOf(IERC20 token) private view returns (ISupplyPosition) {
        return _vault[token].supply();
    }

    function borrowOf(
        IERC20 token
    ) external view override returns (IBorrowPosition) {
        require(enlisted(token), NotEnlisted(token));
        return _borrowOf(token);
    }

    function borrowLockOf(
        address user,
        IERC20 token
    ) external view override returns (uint256) {
        require(enlisted(token), NotEnlisted(token));
        return _borrowOf(token).lockOf(user);
    }

    function _borrowOf(IERC20 token) private view returns (IBorrowPosition) {
        return _vault[token].borrow();
    }

    function vaultOf(IERC20 token) external view override returns (IVault) {
        require(enlisted(token), NotEnlisted(token));
        return _vault[token];
    }

    function weightOf(
        IERC20 token
    ) external view override returns (Weight memory) {
        require(enlisted(token), NotEnlisted(token));
        return _weightOf(token);
    }

    function _weightOf(IERC20 token) private view returns (Weight memory) {
        return
            Weight({
                supply: uint8(parameterOf(WEIGHT_SUPPLY_ID(token))),
                borrow: uint8(parameterOf(WEIGHT_BORROW_ID(token)))
            });
    }

    function wrapperOf(IERC20 token) external view returns (IWPosition) {
        require(enlisted(token), NotEnlisted(token));
        return _wrapper[token];
    }

    mapping(IERC20 t => IWPosition) private _wrapper;

    // ////////////////////////////////////////////////////////////////
    // ////////////////////////////////////////////////////////////////
}
