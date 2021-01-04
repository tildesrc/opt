#!/usr/bin/env bash
set -eu

predependencies=( make sudo equivs git )

[[ -v USER ]] || export USER=$(id --user --name)

if [[ $(id -u) != 0 ]]; then
  source /etc/os-release
  if [[ $ID == "debian" ]]; then
    scripts/add-apt-sources.sh
    [[ -e sources.list ]]
    if cmp /etc/apt/sources.list sources.list; then
      rm sources.list
    else
      INIT_REQUIRED=1
    fi
  fi
  if ! scripts/check_dependencies.sh ${predependencies[@]}; then
      INIT_REQUIRED=1
  fi
  if [[ -v INIT_REQUIRED ]]; then
    echo "Enter root's password when prompted..."
    su --preserve-env --command="$0"
  fi
  sg sudo "make base-system && make install-dependencies && make"
else
  if [[ -e sources.list ]]; then
    cp --verbose /etc/apt/sources.list /etc/apt/sources.list.orig
    <sources.list tee /etc/apt/sources.list
    apt-get update
  fi
  if ! scripts/check_dependencies.sh ${predependencies[@]}; then
    apt-get install --assume-yes ${predependencies[@]}
  fi
  /usr/sbin/usermod --append --groups sudo $USER
fi
