#!/usr/bin/env bash
shopt -s expand_aliases

source .env
source .env-units
alias forge-script='forge script --broadcast --private-key=$PRIVATE_KEY0'
ADMIN=$(cast wallet address --private-key $PRIVATE_KEY0)
POOL_IDX=${1-1}

##
## 📋 Enlist [APOW, AVAX]
##

forge-script ./script/pool/enlist-token.s.sol:Run -f $FORK_URL -s 'run(uint,string memory,uint)' $POOL_IDX APOW 0 --verify
forge-script ./script/pool/enlist-token.s.sol:Run -f $FORK_URL -s 'run(uint,string memory,uint)' $POOL_IDX AVAX 1 --verify
forge-script ./script/pool/enwrap-token.s.sol:Run -f $FORK_URL -s 'run(uint,string memory,uint)' $POOL_IDX APOW 0 --verify
forge-script ./script/pool/enwrap-token.s.sol:Run -f $FORK_URL -s 'run(uint,string memory,uint)' $POOL_IDX AVAX 1 --verify

##
## 🛑 [Un]cap [APOW, AVAX]
##

# forge-script ./script/pool/cap-supply.grant-role.s.sol -f $FORK_URL -s 'run(address)' $ADMIN
# forge-script ./script/pool/cap-supply.s.sol:Run -f $FORK_URL -s 'run(uint,string memory,uint)' $POOL_IDX APOW $MAX
# forge-script ./script/pool/cap-supply.s.sol:Run -f $FORK_URL -s 'run(uint,string memory,uint)' $POOL_IDX AVAX $MAX
# forge-script ./script/pool/cap-supply.revoke-role.s.sol -f $FORK_URL -s 'run(address)' $ADMIN

##
## 🧻 Enroll $POOL_IDX into $ACMA
##

forge-script ./script/position/enroll.s.sol:Run -f $FORK_URL -s 'run(uint,string memory)' $POOL_IDX APOW
forge-script ./script/position/enroll.s.sol:Run -f $FORK_URL -s 'run(uint,string memory)' $POOL_IDX AVAX
forge-script ./script/pool/enroll.s.sol:Run -f $FORK_URL -s 'run(uint)' $POOL_IDX
