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

if [[ -v TASK_EXCLUDES ]]; then
  dpkg-query --show --showformat='${db:Status-Status} ${Package}\n' $TASK_EXCLUDES |
    sed -ne 's/installed //p' |
    xargs --no-run-if-empty apt-get install
fi
