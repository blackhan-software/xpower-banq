#!/usr/bin/env bash

function addressOf() {
    ADDRESS_VAR="${1}_ADDRESS"
    echo "${!ADDRESS_VAR}"
}

function cap() {
  echo "$1" | tr '[:upper:]' '[:lower:]' | sed -E 's/^([a-z])/\U\1/'
}
