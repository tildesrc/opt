#!/usr/bin/env bash
set -eu

if [[ $# -ne 1 ]]; then
  echo "Usage: $0 package_name"
fi

package_name="$1"; shift

if [[ "$package_name" == *.deb && -f "$package_name" ]]; then
  dpkg_cmd=dpkg-deb
else
  dpkg_cmd=dpkg-query
fi

$dpkg_cmd --show --showformat='${Depends}\n' $package_name | \
    sed -e 's/([^)]*)//g' -e 's/\s\+//g' -e 's/,\||/\n/g' | sort -u
