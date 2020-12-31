#!/usr/bin/env bash
set -eu

if [[ $# -ne 1 ]]; then
  echo "Usage: $0 deb_name"
fi

deb_name="$1"; shift

comm -12 \
  <(./get-task-depends.sh $deb_name) \
  <(apt-mark showmanual | sort -u) |
  xargs --no-run-if-empty apt-mark auto
