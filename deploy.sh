#!/usr/bin/env bash
set -euo pipefail
cd "$(dirname "$0")"

declare -A nodes=(
  [fluttershy]=10.0.0.2
  [rainbowdash]=10.0.0.3
  [rarity]=10.0.0.4
  [pinkiepie]=10.0.0.5
  [applejack]=10.0.0.6
)

nix build --no-link \
  .#nixosConfigurations.{twilight,fluttershy,rainbowdash,rarity,pinkiepie,applejack}.config.system.build.toplevel

for host in "${!nodes[@]}"; do
  nixos-rebuild switch --flake ".#$host" --target-host "liam@${nodes[$host]}" \
    --ask-sudo-password --use-substitutes
done

sudo nixos-rebuild switch --flake .#twilight
