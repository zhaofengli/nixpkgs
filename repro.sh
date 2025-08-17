#!/usr/bin/env bash
set -euo pipefail
here="$(dirname $0)"
untracked="${here}/untracked"

if [[ "$#" != 1 ]]; then
  >&2 echo "Usage: $0 <name>"
  exit 1
fi

name="$1-$(date +%Y%m%d-%H%M%S)"
dst="${untracked}/${name}"

mkdir -p "${dst}"
>&2 echo "-> ${dst}"

dump_build() {
  path="$1"
  num="$2"

  build_dst="${dst}/${num}"

  if [[ -e "${build_dst}" ]]; then
    >&2 echo "${build_dst} exists!"
    exit 1
  fi

  mkdir "${dst}/${num}"
  cp "${path}/bin/git" "${build_dst}/git"
  >&2 nix-store --realise "${path}" --add-root "${build_dst}/path"
  >&2 nix-store --dump "${path}" >"${build_dst}/nar"
  >&2 nix log "${path}" >"${build_dst}/log"

  echo "${build_dst}"
}

build_valid() {
  build_dst="$1"

  if [[ ! -e "${build_dst}/git" ]]; then
    >&2 echo "No ${build_dst}/git"
    exit 1
  fi

  if codesign -vv "${build_dst}/git"; then
    echo "valid"
  else
    echo "invalid"
  fi
}

run() {
  set -x
  "$@"
  set +x 2>/dev/null
}

out1=$(run sudo nix-build --store local "${here}/repro.nix" --argstr salt "${name}" -A gitFull)
build1=$(dump_build "${out1}" "1")

run sudo nix-store --delete --ignore-liveness --store local "${out1}"

out2=$(run sudo nix-build --store local "${here}/repro.nix" --argstr salt "${name}" -A gitFull)
build2=$(dump_build "${out2}" "2")

>&2 sha256sum ${dst}/*/git

valid1="$(build_valid "${build1}")"
valid2="$(build_valid "${build2}")"
>&2 echo "Build 1: ${valid1}"
>&2 echo "Build 2: ${valid2}"

case "${valid1},${valid2}" in
  "valid,invalid")
    >&2 echo "Reproduced!"
    ;;
  "invalid,invalid")
    >&2 echo "NOT Reproduced - Both times invalid"
    ;;
  "valid,valid")
    >&2 echo "NOT Reproduced - Both times valid"
    ;;
  "invalid,valid")
    >&2 echo "NOT Reproduced - Valid then invalid"
    ;;
esac
