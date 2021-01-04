#!/usr/bin/env bash
set -eu

if [[ $# -ne 1 ]]; then
  echo "Useage: $0 task_name"
  exit 1
fi

task_name="$1"; shift

exec 3>&1
exec 1>&2

if ! [[ -e $task_name ]]; then
  <$task_name.template sed -e 's/^\([^#]*\)#.*$/\1/' | grep -v '^\s*$' >$task_name
fi
if dpkg-query --show $task_name; then
  version=$(dpkg-query --show --showformat='${Version}\n' $task_name)
  major_version=$(<<<"$version" sed -e 's/\..*$//')
  minor_version=$(<<<"$version" sed -e 's/^.*\.//')
  let "minor_version += 1"
else
  major_version=0
  minor_version=1
fi
version="$major_version.$minor_version"

(
  <$task_name.template grep -v -e '^\s*Version:' -e '^\s*Depends:'
  echo "Version: $version"
  comm -23 <(sort -u $task_name.includes) <(sort -u $task_name.excludes) |
    grep -v '^\s*$' |
    sed -e 's/$/,/g' |
    xargs echo Depends: |
    sed -e 's/,\s*$//'
) >$task_name

equivs-build $task_name
deb_path="$PWD"/"$task_name"_"$version"_all.deb
[[ -e "$deb_path" ]]
mv --verbose "$deb_path" "$task_name"_current_all.deb
