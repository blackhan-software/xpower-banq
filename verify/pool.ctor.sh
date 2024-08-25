#!/usr/bin/env bash
###############################################################################
CMD_SCRIPT=$(cd "$(dirname "${BASH_SOURCE[0]}")" >/dev/null 2>&1 && pwd)
###############################################################################

source "$CMD_SCRIPT/../.env"
source "$CMD_SCRIPT/assert.sh"
source "$CMD_SCRIPT/function.sh"

###############################################################################
###############################################################################

POOL="$(printf "P%03d" "${1-0}")"
POOL_ADDRESS="$(addressOf "$POOL")"
assert "$POOL_ADDRESS" "${POOL}_ADDRESS unset"

VERIFIER="${2-etherscan}"
assert "$VERIFIER" "VERIFIER unset"
CHAIN="${3-avalanche}"
assert "$CHAIN" "CHAIN unset"

forge verify-contract \
    "$POOL_ADDRESS" \
    "source/contract/Pool.sol:Pool" \
    --chain "$CHAIN" \
    --guess-constructor-args \
    --compiler-version v0.8.29+commit.ab55807c \
    --num-of-optimizations 200 \
    --verifier "$VERIFIER" \
    --rpc-url $FORK_URL \
    --watch

###############################################################################
###############################################################################
