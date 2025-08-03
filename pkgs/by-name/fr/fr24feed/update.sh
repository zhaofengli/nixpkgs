#!/usr/bin/env nix-shell
#!nix-shell -i bash -p jq curl common-updater-scripts
set -euo pipefail

if [[ "$#" != "0" ]]; then
  version="$1"
else
  versions_json="$(curl -s https://repo-feed.flightradar24.com/fr24feed_versions.json)"
  version="$(echo "${versions_json}" | jq -r .platform.linux_x86_tgz.version)"
fi

>&2 echo "Updating to ${version}"
here="$(dirname "$0")"

prefetch() {
  nix_platform="$1"
  url="$2"

  sha256="$(nix-prefetch-url "${url}")"

  cat <<EOF
  "${nix_platform}" = {
    url = "${url}";
    sha256 = "${sha256}";
  };
EOF
}

sed -i -E "s/version = \".+\"/version = \"${version}\"/" "${here}/package.nix"

(
  echo "{"
  prefetch "x86_64-linux" "https://repo-feed.flightradar24.com/linux_binaries/fr24feed_${version}_amd64.tgz"
  prefetch "aarch64-linux" "https://repo-feed.flightradar24.com/rpi_binaries/fr24feed_${version}_arm64.tgz"
  echo "}"
) >"${here}/sources.nix"
