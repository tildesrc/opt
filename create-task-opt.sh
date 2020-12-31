#!/usr/bin/env bash
set -eu

exec 3>&1
exec 1>&2

if ! [[ -e task-opt ]]; then
  <task-opt.template sed -e 's/^\([^#]*\)#.*$/\1/' | grep -v '^\s*$' >task-opt
fi
if dpkg-query --show task-opt; then
  version=$(dpkg-query --show --showformat='${Version}\n' task-opt)
  major_version=$(<<<"$version" sed -e 's/\..*$//')
  minor_version=$(<<<"$version" sed -e 's/^.*\.//')
  let "minor_version += 1"
else
  major_version=0
  minor_version=1
fi
version="$major_version.$minor_version"

(
  <task-opt.template grep -v -e '^\s*Version:' -e '^\s*Depends:'
  echo "Version: $version"
	<dependencies.list sed -e 's/\s\+/\n/g' |
    grep -v '^\s*$' |
    sort -u |
    sed -e 's/$/,/g' |
    xargs echo Depends: |
    sed -e 's/,\s*$//'
) >task-opt

equivs-build task-opt
deb_path="$PWD/task-opt_"$version"_all.deb"
[[ -e "$deb_path" ]]
mv --verbose "$deb_path" task-opt_current_all.deb
