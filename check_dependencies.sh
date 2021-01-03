#!/usr/bin/env bash
set -eu

if [[ $# -eq 0 ]]; then
  echo "Usage: $0 package0 [ package1 ... ]"
  exit 1
fi

while [[ 0 -lt $# ]]; do
  dpkg-query --show --showformat='${db:Status-Status}\n' $1 |
    grep --line-regexp --fixed-strings --silent 'installed'
  shift
done
