## XPower Banq: Lending & Borrowing

> Permissionless (or permissioned) DeFi lending and borrowing pools for ERC20
> tokens! 🏄‍♂️

## Installation

```sh
npm install
```

## Usage

See: https://book.getfoundry.sh

### Build

```sh
forge build
```

### Test

```sh
forge test
```

### Format

```sh
forge fmt
```

### Gas Snapshots

```sh
forge snapshot
```

### Anvil

```sh
anvil
```

## Deploy

### Preparation

🤖 Import environment variables: e.g. for `mainnet`, `testnet` or `hostnet`
(i.e. `anvil`)

```sh
cp .env.mainnet .env && source .env && source .env-units
```

🦾 Create a `forge-script` alias: e.g. with a private key

```sh
alias forge-script="forge script --broadcast -f $FORK_URL --private-key=$PRIVATE_KEY0"
```

🦾 Or, create a `forge-script` alias: e.g. with a Ledger and an HD path

```sh
alias forge-script="forge script --broadcast -f $FORK_URL -l --hd-paths \"m/44'/60'/0'/0/0\""
```

**NOTE:** The right-most `0` indicates the mnemonic-index, while the
`m/44'/60'/0'/0` HD path can be used for Ledger Live addresses!

### Preparation: on `anvil` hostnet only

🧪 Create mocks: for [`APOW`,`XPOW`,`AVAX`,`USDC`,`USDT`] tokens

```sh
RUN='run(uint supply,string memory symbol)'
```

```sh
forge-script ./script/token/create-mock.s.sol -s "$RUN" $E22 APOW
forge-script ./script/token/create-mock.s.sol -s "$RUN" $E22 XPOW
forge-script ./script/token/create-mock.s.sol -s "$RUN" $E22 AVAX
forge-script ./script/token/create-mock.s.sol -s "$RUN" $E22 USDC
forge-script ./script/token/create-mock.s.sol -s "$RUN" $E22 USDT
```

**NOTE:** Ensure to update the `APOW_ADDRESS` et alia `.env` variables.

💱 Create mocks: for [`APOW/XPOW`,`APOW/AVAX`,`APOW/USDC`,`APOW/USDT`] feeds

```sh
RUN='run(uint bid,string memory symbol,uint ask,string memory symbol)'
```

```sh
forge-script ./script/feed/create-mock.s.sol -s "$RUN" 100 APOW 200 XPOW
forge-script ./script/feed/create-mock.s.sol -s "$RUN" 200 XPOW 100 APOW
forge-script ./script/feed/create-mock.s.sol -s "$RUN" 100 APOW 300 AVAX
forge-script ./script/feed/create-mock.s.sol -s "$RUN" 300 AVAX 100 APOW
forge-script ./script/feed/create-mock.s.sol -s "$RUN" 100 APOW 400 USDC
forge-script ./script/feed/create-mock.s.sol -s "$RUN" 400 USDC 100 APOW
forge-script ./script/feed/create-mock.s.sol -s "$RUN" 100 APOW 400 USDT
forge-script ./script/feed/create-mock.s.sol -s "$RUN" 400 USDT 100 APOW
```

**NOTE:** Later — _after_ deploying the other contracts — these feeds are to be
enlisted into their oracles _manually_. Hence, keep the logs of the
`ABCD/XYZT FEED_ADDRESS`!

### Execution

🔑 Deploy `ACMA` access manager: with `BOSS` as initial admin

```sh
forge-script ./script/authority/deploy.s.sol:Run --verify
```

🪬 Deploy `T000` oracle: with [`APOW`, `XPOW`] tokens

```sh
forge-script ./script/oracle/deploy-tj.s.sol:Run -s 'run(uint,bool with_feeds)' 0 false --verify ## use `true` for *hard-coded* mainnet feeds!
```

🪬 Deploy `T001` oracle: with [`APOW`, `AVAX`] tokens

```sh
forge-script ./script/oracle/deploy-tj.s.sol:Run -s 'run(uint,bool with_feeds)' 1 false --verify ## use `true` for *hard-coded* mainnet feeds!
```

🪬 Deploy `T002` oracle: with [`APOW`, `USDC`] tokens

```sh
forge-script ./script/oracle/deploy-tj.s.sol:Run -s 'run(uint,bool with_feeds)' 2 false --verify ## use `true` for *hard-coded* mainnet feeds!
```

🪬 Deploy `T003` oracle: with [`APOW`, `USDT`] tokens

```sh
forge-script ./script/oracle/deploy-tj.s.sol:Run -s 'run(uint,bool with_feeds)' 3 false --verify ## use `true` for *hard-coded* mainnet feeds!
```

**NOTE:** The oracles should be deployed onto the **Avalanche mainnet** with the
`with_feeds` flag set to `true`! Otherwise, the feeds need to be _created_ and
_enlisted_ manually. Also, ensure to update the `T00?_ADDRESS` `.env` variables.

🌊 Deploy `P000` pool: with [`APOW`, `XPOW`] tokens

```sh
forge-script ./script/pool/deploy.s.sol:Run -s 'run(uint,string memory,string[] memory)' 0 T000 [APOW,XPOW] --verify
```

🌊 Deploy `P001` pool: with [`APOW`, `AVAX`] tokens

```sh
forge-script ./script/pool/deploy.s.sol:Run -s 'run(uint,string memory,string[] memory)' 1 T001 [APOW,AVAX] --verify
```

🌊 Deploy `P002` pool: with [`APOW`, `USDC`] tokens

```sh
forge-script ./script/pool/deploy.s.sol:Run -s 'run(uint,string memory,string[] memory)' 2 T002 [APOW,USDC] --verify
```

🌊 Deploy `P003` pool: with [`APOW`, `USDT`] tokens

```sh
forge-script ./script/pool/deploy.s.sol:Run -s 'run(uint,string memory,string[] memory)' 3 T003 [APOW,USDT] --verify
```

**NOTE:** Ensure to update the `P00?_ADDRESS` `.env` variables.

🎬 Init `P000` pool: with [`APOW`, `XPOW`] tokens

```sh
./script/pool.sh/init-0.sh ## enlist tokens & cap-{supply=max,borrow}
```

🎬 Init `P001` pool: with [`APOW`, `AVAX`] tokens

```sh
./script/pool.sh/init-1.sh ## enlist tokens & cap-{supply=max,borrow}
```

🎬 Init `P002` pool: with [`APOW`, `USDC`] tokens

```sh
./script/pool.sh/init-3.sh ## enlist tokens & cap-{supply=max,borrow}
```

🎬 Init `P003` pool: with [`APOW`, `USDT`] tokens

```sh
./script/pool.sh/init-3.sh ## enlist tokens & cap-{supply=max,borrow}
```

**NOTE:** The scripts include some contract verification! But, to verify with
yet another blockchain explorer the logs should be saved to the `init-?.log`
files, and then `./verify/pool.init.sh` should be invoked with the correct
contract addresses (contained within the logs).

**NOTE:** Further, on the `anvil` hostnet the `--verify` flags should be
_commented_ out — to avoid verificiation errors.

⚙️ Set-up `ACMA` access manager: label-roles & set-role-admins

```sh
forge-script ./script/authority/setup.s.sol:Run
```

**NOTE:** On the `anvil` hostnet, the setup of the access manager is best to be
_postponed_, until the aforementioned mock feeds have been enlisted into their
respective oracles; see [feed managment](#feed-management).

## Pool

🤖 Import token units: in scientific notation

```sh
source .env-units ## echo $E18, $E6
```

🦾 Define `POOL`: ensure `BNQ{POOL}_ADDRESS` is set!

```sh
export POOL=1 ## echo $BNQ1_ADDRESS
```

### Token Cap Management

🛑 Cap `XPOW` supply: to at most MAX units

```sh
forge-script ./script/pool/cap-supply.s.sol:Run -s 'run(uint,string memory,uint)' $POOL XPOW $MAX
```

🛑 Cap `XPOW` borrow: to at most MAX units

```sh
forge-script ./script/pool/cap-borrow.s.sol:Run -s 'run(uint,string memory,uint)' $POOL XPOW $MAX
```

### Position Management

💸 Supply `APOW`: 1'000 units into pool

```sh
forge-script ./script/position/supply.s.sol:Run -s 'run(uint,string memory,uint)' $POOL APOW $E21 --sender=$SENDER
```

💳 Borrow `APOW`: one unit from pool

```sh
forge-script ./script/position/borrow.s.sol:Run -s 'run(uint,string memory,uint)' $POOL APOW $E18 --sender=$SENDER
```

🤑 Settle `APOW`: one unit into pool

```sh
forge-script ./script/position/settle.s.sol:Run -s 'run(uint,string memory,uint)' $POOL APOW $E18 --sender=$SENDER
```

💰 Redeem `APOW`: 1'000 units from pool

```sh
forge-script ./script/position/redeem.s.sol:Run -s 'run(uint,string memory,uint)' $POOL APOW $E21 --sender=$SENDER
```

### User Management

🫠 Liquidate `$USER`'s positions:

```sh
forge-script ./script/user/liquidate.s.sol:Run -s 'run(uint,address)' $POOL $USER ## 0x...
```

## Oracle

🦾 Define `ORACLE`: ensure `{ORACLE}_ADDRESS` is set!

```sh
export ORACLE=T000 ## echo $T000_ADDRESS
```

### Feed Query

💹 Fetch `XPOW/APOW` (bid, ask)-quotes:

```sh
forge-script ./script/oracle/get-quotes.s.sol -s 'run(string memory,string memory,string memory)' $ORACLE XPOW APOW
```

💹 Fetch `XPOW/APOW` mid-quote: mean of bid and ask

```sh
forge-script ./script/oracle/get-quote.s.sol -s 'run(string memory,string memory,string memory)' $ORACLE XPOW APOW
```

### Feed Refresh

🔃 Refresh `XPOW/APOW` feed: _public_ invocation (if enabled)

```sh
forge-script ./script/oracle/refresh-feed.s.sol -s 'run(string memory,string memory,string memory)' $ORACLE XPOW APOW
```

🔃 Refresh `XPOW/APOW` feed: _permissioned_ invocation

```sh
forge-script ./script/oracle/retwap-feed.s.sol -s 'run(string memory,string memory,string memory)' $ORACLE XPOW APOW
```

**NOTE:** If the `RETWAP` has _not_ been assigned to the `$ORACLE` itself, then
a _public_ invocation of the `refresh-feed.s` script is disallowed. However, any
account with that role can use the _permissioned_ `retwap-feed.s` script.

### Feed Management

➕ Enlist `XPOW/APOW` feed:

```sh
forge-script ./script/oracle/enlist-feed.s.sol:Run -s 'run(string memory,string memory,string memory,address)' $ORACLE XPOW APOW 0x...
```

## Feed

### Feed Creation

➕ Create mock feeds: e.g. on `anvil` hostnet

```sh
forge-script ./script/feed/create-mock.s.sol:Run -s 'run(uint256,string memory,uint256,string memory)' $BID $BID_SYMBOL $ASK $ASK_SYMBOL
```

➕ Create TraderJoe feeds v1.0:

```sh
forge-script ./script/feed/tj/create-v1.0.s.sol:Run -s 'run(address)' $TJ_PAIR ## forward feed
```

```sh
forge-script ./script/feed/tj/create-r1.0.s.sol:Run -s 'run(address)' $TJ_PAIR ## reverse feed
```

➕ Create TraderJoe feeds v2.1:

```sh
forge-script ./script/feed/tj/create-v2.1.s.sol:Run -s 'run(address)' $TJ_PAIR ## forward feed
```

```sh
forge-script ./script/feed/tj/create-r2.1.s.sol:Run -s 'run(address)' $TJ_PAIR ## reverse feed
```

➕ Create Chainlink feeds v3.0:

```sh
forge-script ./script/feed/cl/create-v3.0.s.sol:Run -s 'run(address,address,address)' $CL_AGGREGATOR $BID_TOKEN $ASK_TOKEN ## forward feed
```

```sh
forge-script ./script/feed/cl/create-r3.0.s.sol:Run -s 'run(address,address,address)' $CL_AGGREGATOR $BID_TOKEN $ASK_TOKEN ## inverse feed
```

**NOTE:** For Chainlink feeds, if one of the bid- or ask-tokens represents `USD`
(dollars) — but _not_ `USDC` or `USDT` — then `0x1` should be used as a
pseudo-address!

## Copyright

© 2025 [Moorhead LLC](#)
