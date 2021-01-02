#!/usr/bin/env bash
set -eu

predependencies=( make sudo equivs )

if [[ -v INIT_REQUIRED ]]; then
  if [[ $(id -u) != 0 ]]; then
    echo "Enter root's password when prompted..."
    su --preserve-env --command="$0"
    make base-system
  else
    if [[ -e sources.list ]]; then
      cp --verbose /etc/apt/sources.list /etc/apt/sources.list.orig
      <sources.list tee /etc/apt/sources.list
      apt-get update
    fi
    apt-get install --assume-yes ${predependencies[@]}
  fi
else
  if ! ./check_dependencies.sh ${predependencies[@]}; then
    INIT_REQUIRED=1
  fi

  ./add-apt-sources.sh
  [[ -e sources.list ]]
  if cmp /etc/apt/sources.list sources.list; then
    rm sources.list
  else
    INIT_REQUIRED=1
  fi

  if [[ -v INIT_REQUIRED ]]; then
    export INIT_REQUIRED
    exec "$0"
  fi
fi
