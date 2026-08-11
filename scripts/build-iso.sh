#!/usr/bin/env bash
set -euo pipefail
root="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
runtime="${1:-$root/build/forge-dist}"
work="$root/build/archiso-work"; out="$root/build/iso"; profile="$root/build/archiso-profile"
command -v mkarchiso >/dev/null || { echo 'Install archiso first.' >&2; exit 1; }
[[ -d "$runtime" ]] || { echo "Missing packaged runtime: $runtime" >&2; exit 1; }
rm -rf -- "$profile" "$work"
cp -a /usr/share/archiso/configs/releng "$profile"
install -d "$profile/airootfs/opt/forge/current" "$profile/airootfs/opt/forge-os"
cp -a "$runtime/." "$profile/airootfs/opt/forge/current/"
git -C "$root" archive HEAD | tar -x -C "$profile/airootfs/opt/forge-os"
sed -i 's/^iso_name=.*/iso_name="forge-os"/' "$profile/profiledef.sh"
sed -i 's/^iso_label=.*/iso_label="FORGE_OS"/' "$profile/profiledef.sh"
while IFS= read -r package; do grep -qxF "$package" "$profile/packages.x86_64" || printf '%s\n' "$package" >>"$profile/packages.x86_64"; done < <(sed -e 's/#.*$//' -e '/^[[:space:]]*$/d' "$root/manifests/arch-packages.txt")
mkdir -p "$out"
sudo mkarchiso -v -w "$work" -o "$out" "$profile"
sha256sum "$out"/*.iso | tee "$out/SHA256SUMS"
