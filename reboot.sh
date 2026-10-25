#!/usr/bin/env bash
set -uo pipefail

declare -A nodes=(
  [fluttershy]=10.0.0.2
  [rainbowdash]=10.0.0.3
  [rarity]=10.0.0.4
  [pinkiepie]=10.0.0.5
  [applejack]=10.0.0.6
)

boot_id() {
  ssh -o BatchMode=yes -o ConnectTimeout=3 "liam@$1" cat /proc/sys/kernel/random/boot_id 2>/dev/null
}

for host in "${!nodes[@]}"; do
  ip=${nodes[$host]}
  echo "== $host"
  old=$(boot_id "$ip") || { echo "$host unreachable, stopping"; exit 1; }
  ssh -t "liam@$ip" 'sudo systemctl reboot'

  # Wait up to 5 minutes for it to come back on a new boot
  new=
  for _ in {1..60}; do
    sleep 5
    new=$(boot_id "$ip") && [[ $new != "$old" ]] && break
    new=
  done
  [[ -n $new ]] || { echo "$host didn't come back, stopping"; exit 1; }

  # Make sure it stays up rather than crash-looping
  sleep 90
  [[ $(boot_id "$ip") == "$new" ]] || { echo "$host didn't stay up, stopping"; exit 1; }
  echo "$host is back"
done

read -rp "Reboot twilight too? [y/N] " answer
if [[ $answer == [yY] ]]; then
  sudo systemctl reboot
fi

