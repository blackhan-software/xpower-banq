# Slither Report

```sh
slither . \
    --exclude=naming-conventions \
    --filter-paths=node_modules \
    --show-ignored-findings \
    --checklist > slither.md
```

## Summary

- [arbitrary-send-erc20](#arbitrary-send-erc20) (2 results) (High)
- [incorrect-equality](#incorrect-equality) (6 results) (Medium)
- [unused-return](#unused-return) (6 results) (Medium)
- [timestamp](#timestamp) (16 results) (Low)
- [function-init-state](#function-init-state) (2 results) (Informational)
- [low-level-calls](#low-level-calls) (2 results) (Informational)
- [too-many-digits](#too-many-digits) (4 results) (Informational)
- [unused-state](#unused-state) (3 results) (Informational)

## arbitrary-send-erc20

Impact: High Confidence: High

- [ ] ID-0
      [Pool._square(address,address,uint8)](source/contract/Pool.sol#L429-L463)
      uses arbitrary from in transferFrom:
      [assert(bool)(sp.transferFrom(victim,user,supplied))](source/contract/Pool.sol#L460)

source/contract/Pool.sol#L429-L463

- [ ] ID-1
      [Pool._square(address,address,uint8)](source/contract/Pool.sol#L429-L463)
      uses arbitrary from in transferFrom:
      [t.safeTransferFrom(user,address(this),borrowed)](source/contract/Pool.sol#L444)

source/contract/Pool.sol#L429-L463

## incorrect-equality

Impact: Medium Confidence: High

- [ ] ID-2
      [RateLimited.ratelimited(uint256,uint256,bytes32)](source/contract/modifier/RateLimited.sol#L22-L49)
      uses a dangerous strict equality:
  - [_floor[key] == 0 && floor_cost > 0](source/contract/modifier/RateLimited.sol#L43)

source/contract/modifier/RateLimited.sol#L22-L49

- [ ] ID-3
      [Position._update(address,address,uint256)](source/contract/Position.sol#L293-L341)
      uses a dangerous strict equality:
  - [value > 0 && balanceOf(to) == 0](source/contract/Position.sol#L333)

source/contract/Position.sol#L293-L341

- [ ] ID-4
      [Delayed.delayed(uint256,bytes32)](source/contract/modifier/Delayed.sol#L19-L37)
      uses a dangerous strict equality:
  - [_times[key] == 0 || (yet > _times[key] + dt && dt > 0)](source/contract/modifier/Delayed.sol#L23)

source/contract/modifier/Delayed.sol#L19-L37

- [ ] ID-5
      [RateLimited.ratelimitedOf(bytes32)](source/contract/modifier/RateLimited.sol#L58-L67)
      uses a dangerous strict equality:
  - [_total[key] == 0 && _times[key] > 0](source/contract/modifier/RateLimited.sol#L63)

source/contract/modifier/RateLimited.sol#L58-L67

- [ ] ID-6
      [Position.cap(uint256,uint256)](source/contract/Position.sol#L94-L122)
      uses a dangerous strict equality:
  - [timestamp == type()(uint256).max](source/contract/Position.sol#L100)

source/contract/Position.sol#L94-L122

- [ ] ID-7
      [Position._update(address,address,uint256)](source/contract/Position.sol#L293-L341)
      uses a dangerous strict equality:
  - [value > 0 && balanceOf(from) == value](source/contract/Position.sol#L322)

source/contract/Position.sol#L293-L341

## unused-return

Impact: Medium Confidence: Medium

- [ ] ID-8
      [Feed_V3.getQuotes(uint256)](source/contract/feed/chainlink/Feed-v3.0.sol#L25-L35)
      ignores return value by
      [(None,answer,None,None,None) = _feed.latestRoundData()](source/contract/feed/chainlink/Feed-v3.0.sol#L29)

source/contract/feed/chainlink/Feed-v3.0.sol#L25-L35

- [ ] ID-9
      [Feed_V2._bidOf(uint128,bool)](source/contract/feed/traderjoe/Feed-v2.1.sol#L43-L50)
      ignores return value by
      [(left,bid,None) = _pair.getSwapOut(amount,flag)](source/contract/feed/traderjoe/Feed-v2.1.sol#L45)

source/contract/feed/traderjoe/Feed-v2.1.sol#L43-L50

- [ ] ID-10
      [Feed_V2._askOf(uint128,bool)](source/contract/feed/traderjoe/Feed-v2.1.sol#L52-L59)
      ignores return value by
      [(ask,left,None) = _pair.getSwapIn(amount,flag)](source/contract/feed/traderjoe/Feed-v2.1.sol#L54)

source/contract/feed/traderjoe/Feed-v2.1.sol#L52-L59

- [ ] ID-11
      [Feed_V1.getQuotes(uint256)](source/contract/feed/traderjoe/Feed-v1.0.sol#L31-L38)
      ignores return value by
      [(lhs,rhs,None) = _pair.getReserves()](source/contract/feed/traderjoe/Feed-v1.0.sol#L35)

source/contract/feed/traderjoe/Feed-v1.0.sol#L31-L38

- [ ] ID-12
      [Feed_R3.getQuotes(uint256)](source/contract/feed/chainlink/Feed-v3.0.sol#L51-L61)
      ignores return value by
      [(None,answer,None,None,None) = _feed.latestRoundData()](source/contract/feed/chainlink/Feed-v3.0.sol#L55)

source/contract/feed/chainlink/Feed-v3.0.sol#L51-L61

- [ ] ID-13
      [Feed_R1.getQuotes(uint256)](source/contract/feed/traderjoe/Feed-v1.0.sol#L74-L80)
      ignores return value by
      [(rhs,lhs,None) = _pair.getReserves()](source/contract/feed/traderjoe/Feed-v1.0.sol#L78)

source/contract/feed/traderjoe/Feed-v1.0.sol#L74-L80

## timestamp

Impact: Low Confidence: Medium

- [ ] ID-14 [Position._relLimit()](source/contract/Position.sol#L157-L161) uses
      timestamp for comparisons Dangerous comparisons:
  - [limit > total](source/contract/Position.sol#L160)

source/contract/Position.sol#L157-L161

- [ ] ID-15
      [Oracle._enlist(IERC20,IERC20,IFeed,uint256)](source/contract/Oracle.sol#L67-L88)
      uses timestamp for comparisons Dangerous comparisons:
  - [feed != old_feed && old_dt > 0](source/contract/Oracle.sol#L77)
  - [feed == old_feed && old_dt > new_dt](source/contract/Oracle.sol#L82)

source/contract/Oracle.sol#L67-L88

- [ ] ID-16
      [Delayed.delayedOf(bytes32)](source/contract/modifier/Delayed.sol#L46-L55)
      uses timestamp for comparisons Dangerous comparisons:
  - [key_times > yet](source/contract/modifier/Delayed.sol#L51)

source/contract/modifier/Delayed.sol#L46-L55

- [ ] ID-17
      [SupplyPosition._indexOf2(uint256)](source/contract/Position.sol#L484-L496)
      uses timestamp for comparisons Dangerous comparisons:
  - [dt > 0](source/contract/Position.sol#L488)

source/contract/Position.sol#L484-L496

- [ ] ID-18 [Pool._checkHealth(address)](source/contract/Pool.sol#L465-L470)
      uses timestamp for comparisons Dangerous comparisons:
  - [h.wnav_supply < h.wnav_borrow](source/contract/Pool.sol#L467)

source/contract/Pool.sol#L465-L470

- [ ] ID-19
      [Oracle.refreshed(IERC20,IERC20)](source/contract/Oracle.sol#L215-L222)
      uses timestamp for comparisons Dangerous comparisons:
  - [block.timestamp < twap.last.time + limit](source/contract/Oracle.sol#L221)

source/contract/Oracle.sol#L215-L222

- [ ] ID-20
      [Position.cap(uint256,uint256)](source/contract/Position.sol#L94-L122)
      uses timestamp for comparisons Dangerous comparisons:
  - [timestamp == type()(uint256).max](source/contract/Position.sol#L100)
  - [target > limit || dt != type()(uint256).max](source/contract/Position.sol#L101)
  - [yet < tmp - dt](source/contract/Position.sol#L112)
  - [timestamp > yet && target < limit](source/contract/Position.sol#L115)
  - [timestamp > tmp](source/contract/Position.sol#L118)

source/contract/Position.sol#L94-L122

- [ ] ID-21 [Position.index()](source/contract/Position.sol#L382-L389) uses
      timestamp for comparisons Dangerous comparisons:
  - [stamp > _stamp](source/contract/Position.sol#L384)

source/contract/Position.sol#L382-L389

- [ ] ID-22
      [Parameterized._setTargetIf(uint256,uint256,uint256)](source/contract/governance/Parameterized.sol#L72-L95)
      uses timestamp for comparisons Dangerous comparisons:
  - [value != old_value && old_dt > 0](source/contract/governance/Parameterized.sol#L87)
  - [value == old_value && old_dt > new_dt](source/contract/governance/Parameterized.sol#L91)

source/contract/governance/Parameterized.sol#L72-L95

- [ ] ID-23
      [Pool.square(address,address,uint8)](source/contract/Pool.sol#L415-L426)
      uses timestamp for comparisons Dangerous comparisons:
  - [h.wnav_supply >= h.wnav_borrow](source/contract/Pool.sol#L421)

source/contract/Pool.sol#L415-L426

- [ ] ID-24 [Position._reindex()](source/contract/Position.sol#L373-L380) uses
      timestamp for comparisons Dangerous comparisons:
  - [stamp > _stamp](source/contract/Position.sol#L375)

source/contract/Position.sol#L373-L380

- [ ] ID-25
      [BorrowPosition._indexOf2(uint256)](source/contract/Position.sol#L596-L608)
      uses timestamp for comparisons Dangerous comparisons:
  - [dt > 0](source/contract/Position.sol#L600)

source/contract/Position.sol#L596-L608

- [ ] ID-26
      [Position.mint(address,uint256,bool)](source/contract/Position.sol#L218-L236)
      uses timestamp for comparisons Dangerous comparisons:
  - [amount + totalSupply() > abs_limit](source/contract/Position.sol#L224)
  - [amount > rel_limit](source/contract/Position.sol#L228)

source/contract/Position.sol#L218-L236

- [ ] ID-27
      [Parameterized._durationTo(uint256)](source/contract/governance/Parameterized.sol#L112-L117)
      uses timestamp for comparisons Dangerous comparisons:
  - [timestamp > block.timestamp](source/contract/governance/Parameterized.sol#L113)

source/contract/governance/Parameterized.sol#L112-L117

- [ ] ID-28
      [RateLimited.ratelimitedOf(bytes32)](source/contract/modifier/RateLimited.sol#L58-L67)
      uses timestamp for comparisons Dangerous comparisons:
  - [_total[key] == 0 && _times[key] > 0](source/contract/modifier/RateLimited.sol#L63)
  - [(0,yet - _times[key] < _floor[key])](source/contract/modifier/RateLimited.sol#L64)

source/contract/modifier/RateLimited.sol#L58-L67

- [ ] ID-29
      [Limited.limitedOf(bytes32)](source/contract/modifier/Limited.sol#L37-L45)
      uses timestamp for comparisons Dangerous comparisons:
  - [_times[key] > yet](source/contract/modifier/Limited.sol#L41)

source/contract/modifier/Limited.sol#L37-L45

## function-init-state

Impact: Informational Confidence: High

- [ ] ID-30
      [Parameterized.FOR_3M](source/contract/governance/Parameterized.sol#L146)
      is set pre-construction with a non-constant function or state variable:
  - _timestampOf(Constant.MONTH * 3)

source/contract/governance/Parameterized.sol#L146

- [ ] ID-31
      [Parameterized.FOR_1Y](source/contract/governance/Parameterized.sol#L148)
      is set pre-construction with a non-constant function or state variable:
  - _timestampOf(Constant.YEAR)

source/contract/governance/Parameterized.sol#L148

## low-level-calls

Impact: Informational Confidence: High

- [ ] ID-32 Low level call in
      [Token.decimalsOf(address)](source/library/Token.sol#L44-L55):
  - [(ok,encoded) = asset.staticcall(abi.encodeCall(IERC20Metadata.decimals,()))](source/library/Token.sol#L45-L47)

source/library/Token.sol#L44-L55

- [ ] ID-33 Low level call in
      [Token.symbolOf(address)](source/library/Token.sol#L76-L84):
  - [(ok,encoded) = asset.staticcall(abi.encodeCall(IERC20Metadata.symbol,()))](source/library/Token.sol#L77-L79)

source/library/Token.sol#L76-L84

## too-many-digits

Impact: Informational Confidence: Medium

- [ ] ID-34
      [Oracle_001.slitherConstructorConstantVariables()](source/contract/oracle/chainlink/Oracles.sol#L39-L58)
      uses literals with too many digits:
  - [DECAY_01HL = 0.500000000000000000e18](source/contract/Oracle.sol#L228)

source/contract/oracle/chainlink/Oracles.sol#L39-L58

- [ ] ID-35
      [Oracle_003.slitherConstructorConstantVariables()](source/contract/oracle/traderjoe/Oracles.sol#L82-L101)
      uses literals with too many digits:
  - [DECAY_01HL = 0.500000000000000000e18](source/contract/Oracle.sol#L228)

source/contract/oracle/traderjoe/Oracles.sol#L82-L101

- [ ] ID-36
      [Oracle_000.slitherConstructorConstantVariables()](source/contract/oracle/chainlink/Oracles.sol#L18-L37)
      uses literals with too many digits:
  - [DECAY_01HL = 0.500000000000000000e18](source/contract/Oracle.sol#L228)

source/contract/oracle/chainlink/Oracles.sol#L18-L37

- [ ] ID-37
      [Oracle_002.slitherConstructorConstantVariables()](source/contract/oracle/chainlink/Oracles.sol#L60-L79)
      uses literals with too many digits:
  - [DECAY_01HL = 0.500000000000000000e18](source/contract/Oracle.sol#L228)

source/contract/oracle/chainlink/Oracles.sol#L60-L79

## unused-state

Impact: Informational Confidence: High

- [ ] ID-38
      [Parameterized.FOR_1Y](source/contract/governance/Parameterized.sol#L148)
      is never used in [BorrowPosition](source/contract/Position.sol#L547-L627)

source/contract/governance/Parameterized.sol#L148

- [ ] ID-39
      [Parameterized.FOR_1Y](source/contract/governance/Parameterized.sol#L148)
      is never used in [Vault](source/contract/Vault.sol#L24-L100)

source/contract/governance/Parameterized.sol#L148

- [ ] ID-40
      [Parameterized.FOR_1Y](source/contract/governance/Parameterized.sol#L148)
      is never used in [SupplyPosition](source/contract/Position.sol#L435-L542)

source/contract/governance/Parameterized.sol#L148
