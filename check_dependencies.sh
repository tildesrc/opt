#!/usr/bin/env bash
set -eu

if [[ $# -eq 0 ]]; then
  echo "Usage: $0 package0 [ package1 ... ]"
  exit 1
fi

! dpkg-query --show --showformat='${db:Status-Status}\n' $@ |
  grep --invert --line-regexp --fixed-strings 'installed'
