#!/usr/bin/env bash
set -uo pipefail

declare -A nodes=(
  [fluttershy]=10.0.0.2
  [rainbowdash]=10.0.0.3
  [rarity]=10.0.0.4
  [pinkiepie]=10.0.0.5
  [applejack]=10.0.0.6
)

failed=()
for host in "${!nodes[@]}"; do
  echo "== $host"
  ssh -t "liam@${nodes[$host]}" 'sudo nix-collect-garbage -d' || failed+=("$host")
done

echo "== twilight"
sudo nix-collect-garbage -d || failed+=("twilight")

if ((${#failed[@]})); then
  echo "failed: ${failed[*]}"
  exit 1
fi

