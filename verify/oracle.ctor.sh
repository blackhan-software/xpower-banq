#!/usr/bin/env bash
###############################################################################
CMD_SCRIPT=$(cd "$(dirname "${BASH_SOURCE[0]}")" >/dev/null 2>&1 && pwd)
###############################################################################

source "$CMD_SCRIPT/../.env"
source "$CMD_SCRIPT/assert.sh"
source "$CMD_SCRIPT/function.sh"

###############################################################################
###############################################################################

ORACLE="$(printf "T%03d" "${1-0}")"
ORACLE_NAME="$(cap "$ORACLE")Oracle"
ORACLE_ADDRESS="$(addressOf "$ORACLE")"
assert "$ORACLE_ADDRESS" "${ORACLE}_ADDRESS unset"

VERIFIER="${2-etherscan}"
assert "$VERIFIER" "VERIFIER unset"
CHAIN="${3-avalanche}"
assert "$CHAIN" "CHAIN unset"

forge verify-contract \
    "$ORACLE_ADDRESS" \
    "source/contract/oracle/traderjoe/${ORACLE_NAME}.sol:${ORACLE_NAME}" \
    --chain "$CHAIN" \
    --constructor-args "" \
    --compiler-version v0.8.29+commit.ab55807c \
    --num-of-optimizations 2000 \
    --verifier "$VERIFIER" \
    --watch

###############################################################################
###############################################################################
