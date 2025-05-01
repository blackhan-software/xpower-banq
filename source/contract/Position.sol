// SPDX-License-Identifier: GPL-3.0
pragma solidity ^0.8.28;

import {ERC20Permit} from "@openzeppelin/contracts/token/ERC20/extensions/ERC20Permit.sol";
import {IAccessManager} from "@openzeppelin/contracts/access/manager/AccessManager.sol";
import {IERC20Metadata} from "@openzeppelin/contracts/interfaces/IERC20Metadata.sol";
import {IERC20} from "@openzeppelin/contracts/interfaces/IERC20.sol";
import {ERC20} from "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import {Ownable} from "@openzeppelin/contracts/access/Ownable.sol";
import {Math} from "@openzeppelin/contracts/utils/math/Math.sol";

import {IPosition, IPositionIndex} from "../interface/Position.sol";
import {IPositionRO, IPositionRW} from "../interface/Position.sol";
import {ISupplyPosition} from "../interface/Position.sol";
import {IBorrowPosition} from "../interface/Position.sol";
import {IPoolRO} from "../interface/Pool.sol";

import {Rate, SupplyRate, BorrowRate} from "../library/Rate.sol";
import {Constant} from "../library/Constant.sol";
import {String} from "../library/String.sol";

import {PositionSupervised} from "./supervised/Position.sol";
import {VaultUtil} from "../struct/VaultUtil.sol";
import {IRModel} from "../struct/IRModel.sol";
import {Health} from "../struct/Health.sol";

import {Parameterized} from "./governance/Parameterized.sol";

/**
 * @title Contract to tokenize positions
 */
abstract contract Position is
    PositionSupervised,
    ERC20Permit,
    IPosition,
    Ownable
{
    IERC20Metadata internal immutable _asset;
    IPoolRO internal immutable _pool;

    constructor(
        IPoolRO pool_,
        IERC20Metadata token_,
        IRModel memory model_,
        IAccessManager acma_
    ) PositionSupervised(acma_) Ownable(address(pool_)) {
        _setTarget(SPREAD_ID, model_.spread, FOR_3M);
        _setTarget(RATE_ID, model_.rate, FOR_3M);
        _setTarget(UTIL_ID, model_.util, FOR_3M);
        _asset = token_;
        _pool = pool_;
    }

    // ////////////////////////////////////////////////////////////////
    // IPositionLock
    // ////////////////////////////////////////////////////////////////

    function lockOf(address user) external view override returns (uint256) {
        return _lock[user];
    }

    function _lockMore(address user, uint256 amount) private {
        if (user != address(0)) {
            _lockMore(address(0), amount); // total
        }
        if (_lock[user] <= type(uint256).max - amount) {
            unchecked {
                _lock[user] += amount;
            }
        } else {
            _lock[user] = type(uint256).max;
        }
    }

    function _lockLess(address user, uint256 amount) private {
        if (user != address(0)) {
            _lockLess(address(0), amount); // total
        }
        if (_lock[user] > amount) {
            unchecked {
                _lock[user] -= amount;
            }
        } else {
            _lock[user] = 0;
        }
    }

    mapping(address u => uint256) private _lock;

    // ////////////////////////////////////////////////////////////////
    // IPositionCap
    // ////////////////////////////////////////////////////////////////

    function cap(uint256 limit, uint256 dt) external override onlyOwner {
        (uint256 target, uint256 timestamp) = _tgtLimit();
        //
        // 🔺-mode: target-increase *only* (else cap-constant)
        //
        // slither-disable-next-line incorrect-equality
        if (timestamp == type(uint256).max) {
            if (target > limit || dt != type(uint256).max) {
                revert CapConstant(target, timestamp); // too small
            } else {
                return _tgtLimit(limit, timestamp);
            }
        }
        //
        // 🔻-mode: target-decrease *only* (if&f cap-constant)
        //
        uint256 tmp = type(uint256).max;
        uint256 yet = block.timestamp;
        if (yet < tmp - dt) {
            tmp = yet + dt;
        }
        if (timestamp > yet && target < limit) {
            revert CapConstant(target, timestamp - yet); // too large
        }
        if (timestamp > tmp) {
            revert CapConstant(target, timestamp - yet); // too retro
        }
        _tgtLimit(limit, tmp);
    }

    function cap() external view override returns (uint256 limit, uint256 dt) {
        return _absLimit();
    }

    function capOf(
        address user
    ) external view override returns (uint256 limit, uint256 dt) {
        return _capOf(user);
    }

    function _capOf(
        address user
    ) private view returns (uint256 limit, uint256 dt) {
        uint256 balance = balanceOf(user);
        uint256 total = totalSupply();
        (limit, dt) = _relLimit();
        if (balance > 0 && total > balance) {
            // Beta distribution: 12λ(1−λ)² with λ=balance/total
            limit = Math.mulDiv(limit, total - balance, total);
            limit = Math.mulDiv(limit, total - balance, total);
            limit = Math.mulDiv(limit, balance, total) * 12;
            limit = limit / Math.sqrt(totalHolders + 2);
        } else {
            limit = limit / (totalHolders + 1);
        }
    }

    function _absLimit() private view returns (uint256 limit, uint256 dt) {
        (uint256 target, uint256 timestamp) = _tgtLimit();
        limit = Math.min(target, parameterOf(CAP_ID));
        dt = _durationTo(timestamp);
    }

    function _relLimit() private view returns (uint256 limit, uint256 dt) {
        (limit, dt) = _absLimit();
        uint256 total = totalSupply();
        limit = limit > total ? limit - total : 0;
    }

    function _tgtLimit() private view returns (uint256 limit, uint timestamp) {
        return Parameterized._getTarget(CAP_ID);
    }

    function _tgtLimit(uint256 limit, uint256 timestamp) private {
        if (limit > type(uint224).max) {
            revert TooLarge({id: CAP_ID, value: limit, max: type(uint224).max});
        }
        Parameterized._setTarget(CAP_ID, limit, timestamp);
    }

    // ////////////////////////////////////////////////////////////////
    // IPositionRO
    // ////////////////////////////////////////////////////////////////

    function totalOf(address user) public view override returns (uint256) {
        uint256 principal = _principalOf[user];
        if (principal > 0) {
            uint256 user_index = _userIndex[user];
            if (user_index > 0) {
                uint256 time_index = _indexOf1(block.timestamp - _stamp);
                return Math.mulDiv(principal, time_index, user_index);
            }
            return principal;
        }
        return 0;
    }

    function pool() external view override returns (IPoolRO) {
        return _pool;
    }

    function model() external view returns (IRModel memory) {
        return _model();
    }

    function _model() internal view returns (IRModel memory) {
        return
            IRModel({
                spread: parameterOf(SPREAD_ID),
                rate: parameterOf(RATE_ID),
                util: parameterOf(UTIL_ID)
            });
    }

    function asset() external view override returns (IERC20) {
        return _asset;
    }

    uint256 public totalHolders;

    // ////////////////////////////////////////////////////////////////
    // IPositionRW
    // ////////////////////////////////////////////////////////////////

    function mint(
        address user,
        uint256 amount,
        bool lock
    ) public virtual onlyOwner {
        (uint256 abs_limit, ) = _absLimit();
        if (amount + totalSupply() > abs_limit) {
            revert AbsExceeded(abs_limit);
        }
        (uint256 rel_limit, ) = _capOf(user);
        if (amount > rel_limit) {
            revert RelExceeded(rel_limit);
        }
        if (lock) {
            _lockMore(user, amount);
        }
        _accrueInterest(user);
        _mint(user, amount);
    }

    function burn(
        address user,
        uint256 amount,
        bool unlock
    ) public virtual onlyOwner {
        _accrueInterest(user);
        _burn(user, amount);
        if (unlock) {
            _lockLess(user, amount);
        } else {
            require(totalOf(user) >= _lock[user], Locked(user, _lock[user]));
        }
    }

    function _accrueInterest(address user) internal {
        uint256 amount = _accrueable(user);
        if (amount > 0) _mint(user, amount);
    }

    function _accrueInterest(address user1, address user2) internal {
        if (user1 == user2) {
            return _accrueInterest(user1);
        }
        uint256 amount1 = _accrueable(user1);
        uint256 amount2 = _accrueable(user2);
        if (amount1 > 0) _mint(user1, amount1);
        if (amount2 > 0) _mint(user2, amount2);
    }

    function _accrueable(address user) internal view returns (uint256) {
        uint256 balance_total = totalOf(user);
        uint256 balance = balanceOf(user);
        if (balance_total > balance) {
            return balance_total - balance;
        }
        return 0;
    }

    // ////////////////////////////////////////////////////////////////
    // IERC20Metadata
    // ////////////////////////////////////////////////////////////////

    function decimals()
        public
        view
        override(IERC20Metadata, ERC20)
        returns (uint8)
    {
        return _asset.decimals();
    }

    // ////////////////////////////////////////////////////////////////
    // IERC20
    // ////////////////////////////////////////////////////////////////

    function _update(
        address from,
        address to,
        uint256 value
    ) internal virtual override {
        if (from != address(0)) {
            //
            // Transfer: from => to
            //
            if (to != address(0)) {
                uint256 balance = balanceOf(from);
                if (balance > 0) {
                    uint256 lock = _lock[from];
                    if (lock > 0) {
                        uint256 diff = Math.mulDiv(lock, value, balance);
                        if (diff > 0) {
                            _lockLess(from, diff);
                            _lockMore(to, diff);
                        }
                    }
                }
                _reindexLess(from, value);
                _reindexMore(to, value);
            }
            //
            // Burn: from => to=address(0)
            //
            else {
                // slither-disable-next-line incorrect-equality
                if (value > 0 && balanceOf(from) == value) {
                    _decreaseHolders();
                }
                _reindexLess(from, value);
            }
        } else {
            //
            // Mint: from=address(0) => to
            //
            if (to != address(0)) {
                // slither-disable-next-line incorrect-equality
                if (value > 0 && balanceOf(to) == 0) {
                    _increaseHolders();
                }
                _reindexMore(to, value);
            }
        }
        super._update(from, to, value);
        _reindex(); // position
    }

    function _increaseHolders() private {
        if (totalHolders < type(uint256).max) {
            unchecked {
                totalHolders++;
            }
        }
    }

    function _decreaseHolders() private {
        if (totalHolders > 0) {
            unchecked {
                totalHolders--;
            }
        }
    }

    // ////////////////////////////////////////////////////////////////
    // IPositionIndex: discretization of continuous rates
    // ////////////////////////////////////////////////////////////////

    function reindex()
        external
        limited(
            Constant.DAY,
            keccak256(abi.encodePacked(this.reindex.selector))
        )
    {
        _reindex();
    }

    function _reindex() private {
        uint256 stamp = block.timestamp;
        if (stamp > _stamp) {
            (uint256 idx, uint256 util) = _indexOf2(stamp - _stamp);
            (_index, _stamp) = (idx, stamp);
            emit Reindex(idx, stamp, util);
        }
    }

    function index() external view override returns (uint256, uint256) {
        uint256 stamp = block.timestamp;
        if (stamp > _stamp) {
            uint256 dt = stamp - _stamp;
            return (_indexOf1(dt), dt);
        }
        return (_indexOf1(0), 0);
    }

    function _indexOf1(
        uint256 dt
    ) internal view virtual returns (uint256 value) {
        (value, ) = _indexOf2(dt);
    }

    function _indexOf2(
        uint256 dt
    ) internal view virtual returns (uint256 value, uint256 util);

    function _reindexMore(address user, uint256 amount) private {
        if (_principalOf[user] <= type(uint256).max - amount) {
            unchecked {
                _principalOf[user] += amount;
            }
        } else {
            _principalOf[user] = type(uint256).max;
        }
        _userIndex[user] = _index;
    }

    function _reindexLess(address user, uint256 amount) private {
        if (_principalOf[user] > amount) {
            unchecked {
                _principalOf[user] -= amount;
            }
        } else {
            _principalOf[user] = 0;
        }
        _userIndex[user] = _index;
    }

    mapping(address user => uint256) private _principalOf;
    mapping(address user => uint256) private _userIndex;
    uint256 internal _index = Constant.ONE;
    uint256 internal _stamp; // of index

    // ////////////////////////////////////////////////////////////////
    // ////////////////////////////////////////////////////////////////
}

/**
 * @title Contract to tokenize supply positions
 */
contract SupplyPosition is ISupplyPosition, Position {
    using SupplyRate for IRModel;
    using String for string;

    constructor(
        IPoolRO pool_,
        IERC20Metadata token_,
        IERC20Metadata buddy_,
        IRModel memory model_,
        IAccessManager acma_
    )
        Position(pool_, token_, model_, acma_)
        ERC20(_name(token_), _symbol(token_, buddy_))
        ERC20Permit(_name(token_))
    {
        _stamp = block.timestamp;
    }

    function _name(
        IERC20Metadata token
    ) internal view virtual returns (string memory) {
        return String.join(token.name(), " ", "Supply");
    }

    function _symbol(
        IERC20Metadata token,
        IERC20Metadata buddy
    ) internal view virtual returns (string memory) {
        string memory ts = token.symbol();
        string memory bs = buddy.symbol();
        if (ts.eq("APOW") && bs.eq("XPOW")) {
            return "sAPOW"; // instead of sAPOW:XPOW
        }
        if (ts.eq("XPOW") && bs.eq("APOW")) {
            return "sXPOW"; // instead of sXPOW:APOW
        }
        if (ts.eq("WAVAX")) {
            ts = "AVAX"; // i.e. e.g. sAVAX:APOW
        }
        if (bs.eq("WAVAX")) {
            bs = "AVAX"; // i.e. e.g. sAPOW:AVAX
        }
        return String.join("s", ts, ":", bs);
    }

    // ////////////////////////////////////////////////////////////////
    // IPositionIndex
    // ////////////////////////////////////////////////////////////////

    function _indexOf2(
        uint256 dt
    ) internal view override returns (uint256 value, uint256 util) {
        util = _pool.vaultOf(_asset).util();
        if (dt > 0) {
            uint256 rate_anno = _model().by(util); // utilization => rate
            uint256 rate_part = Math.mulDiv(rate_anno, dt, Constant.YEAR);
            uint256 rate_cont = Rate.accrue(Constant.ONE, rate_part);
            value = Math.mulDiv(_index, rate_cont, Constant.ONE);
        } else {
            value = _index;
        }
    }

    // ////////////////////////////////////////////////////////////////
    // IERC20
    // ////////////////////////////////////////////////////////////////

    function transfer(
        address to,
        uint256 amount
    ) public override(IERC20, ERC20) returns (bool) {
        _accrueInterest(msg.sender, to);
        if (msg.sender == owner()) {
            _transfer(msg.sender, to, amount);
        } else {
            _transfer(msg.sender, to, amount);
            _checkHealth(msg.sender);
        }
        return true;
    }

    function transferFrom(
        address from,
        address to,
        uint256 amount
    ) public override(IERC20, ERC20) returns (bool) {
        _accrueInterest(from, to);
        if (msg.sender == owner()) {
            _transfer(from, to, amount); // liquidation!
        } else {
            _spendAllowance(from, msg.sender, amount);
            _transfer(from, to, amount);
            _checkHealth(from);
        }
        return true;
    }

    function _checkHealth(address user) private view {
        Health memory health = _pool.healthOf(user);
        require(
            health.wnav_supply >= health.wnav_borrow,
            InsufficientHealth(health.wnav_supply, health.wnav_borrow)
        );
    }

    // ////////////////////////////////////////////////////////////////
    // ////////////////////////////////////////////////////////////////
}

/**
 * @title Contract to tokenize borrow positions
 */
contract BorrowPosition is IBorrowPosition, Position {
    using BorrowRate for IRModel;
    using String for string;

    constructor(
        IPoolRO pool_,
        IERC20Metadata token_,
        IERC20Metadata buddy_,
        IRModel memory model_,
        IAccessManager acma_
    )
        Position(pool_, token_, model_, acma_)
        ERC20(_name(token_), _symbol(token_, buddy_))
        ERC20Permit(_name(token_))
    {
        _stamp = block.timestamp;
    }

    function _name(
        IERC20Metadata token
    ) internal view virtual returns (string memory) {
        return String.join(token.name(), " ", "Borrow");
    }

    function _symbol(
        IERC20Metadata token,
        IERC20Metadata buddy
    ) internal view virtual returns (string memory) {
        string memory ts = token.symbol();
        string memory bs = buddy.symbol();
        if (ts.eq("APOW") && bs.eq("XPOW")) {
            return "bAPOW"; // instead of bAPOW:XPOW
        }
        if (ts.eq("XPOW") && bs.eq("APOW")) {
            return "bXPOW"; // instead of bXPOW:APOW
        }
        if (ts.eq("WAVAX")) {
            ts = "AVAX"; // i.e. e.g. bAVAX:APOW
        }
        if (bs.eq("WAVAX")) {
            bs = "AVAX"; // i.e. e.g. bAPOW:AVAX
        }
        return String.join("b", ts, ":", bs);
    }

    // ////////////////////////////////////////////////////////////////
    // IPositionIndex
    // ////////////////////////////////////////////////////////////////

    function _indexOf2(
        uint256 dt
    ) internal view override returns (uint256 value, uint256 util) {
        util = _pool.vaultOf(_asset).util();
        if (dt > 0) {
            uint256 rate_anno = _model().by(util); // utilization => rate
            uint256 rate_part = Math.mulDiv(rate_anno, dt, Constant.YEAR);
            uint256 rate_cont = Rate.accrue(Constant.ONE, rate_part);
            value = Math.mulDiv(_index, rate_cont, Constant.ONE);
        } else {
            value = _index;
        }
    }

    // ////////////////////////////////////////////////////////////////
    // IERC20
    // ////////////////////////////////////////////////////////////////

    function _update(
        address from,
        address to,
        uint256 value
    ) internal virtual override {
        if (from != address(0) && to != address(0)) {
            revert ForbiddenTransfer(from, to);
        }
        super._update(from, to, value);
    }

    // ////////////////////////////////////////////////////////////////
    // ////////////////////////////////////////////////////////////////
}
