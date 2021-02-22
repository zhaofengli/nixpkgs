#!/usr/bin/env nix-shell
#! nix-shell -i bash  -I nixpkgs=../../../.. -p nodePackages.node2nix
set -euo pipefail

node2nix --nodejs-12 \
    --input package.json \
    --lock package-lock.json \
    --output node-packages-generated.nix \
    --composition node-packages.nix \
    --node-env ../../../development/node-packages/node-env.nix \

node2nix --nodejs-12 \
    --development \
    --input package.json \
    --lock package-lock.json \
    --output node-dev-packages-generated.nix \
    --composition node-dev-packages.nix \
    --node-env ../../../development/node-packages/node-env.nix \
