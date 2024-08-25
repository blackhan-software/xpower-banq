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

SP0_ADDRESS="$(addressOf "SP0")"
assert "$SP0_ADDRESS" "SP0_ADDRESS unset"
BP0_ADDRESS="$(addressOf "BP0")"
assert "$BP0_ADDRESS" "BP0_ADDRESS unset"
VT0_ADDRESS="$(addressOf "VT0")"
assert "$VT0_ADDRESS" "VT0_ADDRESS unset"
SP1_ADDRESS="$(addressOf "SP1")"
assert "$SP1_ADDRESS" "SP1_ADDRESS unset"
BP1_ADDRESS="$(addressOf "BP1")"
assert "$BP1_ADDRESS" "BP1_ADDRESS unset"
VT1_ADDRESS="$(addressOf "VT1")"
assert "$VT1_ADDRESS" "VT1_ADDRESS unset"
WP0_ADDRESS="$(addressOf "WP0")"
assert "$WP0_ADDRESS" "WP0_ADDRESS unset"
WP1_ADDRESS="$(addressOf "WP1")"
assert "$WP1_ADDRESS" "WP1_ADDRESS unset"

###############################################################################
###############################################################################

forge verify-contract \
    "$SP0_ADDRESS" \
    "source/contract/Position.sol:SupplyPosition" \
    --chain "$CHAIN" \
    --guess-constructor-args \
    --compiler-version v0.8.29+commit.ab55807c \
    --num-of-optimizations 200 \
    --verifier "$VERIFIER" \
    --rpc-url $FORK_URL \
    --watch

forge verify-contract \
    "$BP0_ADDRESS" \
    "source/contract/Position.sol:BorrowPosition" \
    --chain "$CHAIN" \
    --guess-constructor-args \
    --compiler-version v0.8.29+commit.ab55807c \
    --num-of-optimizations 200 \
    --verifier "$VERIFIER" \
    --rpc-url $FORK_URL \
    --watch

forge verify-contract \
    "$VT0_ADDRESS" \
    "source/contract/Vault.sol:Vault" \
    --chain "$CHAIN" \
    --guess-constructor-args \
    --compiler-version v0.8.29+commit.ab55807c \
    --num-of-optimizations 200 \
    --verifier "$VERIFIER" \
    --rpc-url $FORK_URL \
    --watch

forge verify-contract \
    "$SP1_ADDRESS" \
    "source/contract/Position.sol:SupplyPosition" \
    --chain "$CHAIN" \
    --guess-constructor-args \
    --compiler-version v0.8.29+commit.ab55807c \
    --num-of-optimizations 200 \
    --verifier "$VERIFIER" \
    --rpc-url $FORK_URL \
    --watch

forge verify-contract \
    "$BP1_ADDRESS" \
    "source/contract/Position.sol:BorrowPosition" \
    --chain "$CHAIN" \
    --guess-constructor-args \
    --compiler-version v0.8.29+commit.ab55807c \
    --num-of-optimizations 200 \
    --verifier "$VERIFIER" \
    --rpc-url $FORK_URL \
    --watch

forge verify-contract \
    "$VT1_ADDRESS" \
    "source/contract/Vault.sol:Vault" \
    --chain "$CHAIN" \
    --guess-constructor-args \
    --compiler-version v0.8.29+commit.ab55807c \
    --num-of-optimizations 200 \
    --verifier "$VERIFIER" \
    --rpc-url $FORK_URL \
    --watch

forge verify-contract \
    "$WP0_ADDRESS" \
    "source/contract/WPosition.sol:WPosition" \
    --chain "$CHAIN" \
    --guess-constructor-args \
    --compiler-version v0.8.29+commit.ab55807c \
    --num-of-optimizations 200 \
    --verifier "$VERIFIER" \
    --rpc-url $FORK_URL \
    --watch

forge verify-contract \
    "$WP1_ADDRESS" \
    "source/contract/WPosition.sol:WPosition" \
    --chain "$CHAIN" \
    --guess-constructor-args \
    --compiler-version v0.8.29+commit.ab55807c \
    --num-of-optimizations 200 \
    --verifier "$VERIFIER" \
    --rpc-url $FORK_URL \
    --watch

###############################################################################
###############################################################################
