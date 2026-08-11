#!/usr/bin/env bash
set -euo pipefail

root="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
record="$root/build/latest.env"
[[ -r "$record" ]] || { echo 'Run scripts/build-forge.sh first.' >&2; exit 1; }
source "$record"
runtime="$root/$FORGE_RUNTIME_RELATIVE_PATH"
work="$root/build/archiso-work"
out="$root/build/iso"
profile="$root/build/archiso-profile"
command -v mkarchiso >/dev/null || { echo 'Install archiso first.' >&2; exit 1; }
[[ -x "$runtime/forge" && -r "$runtime/resources/app.asar" ]] || { echo "Incomplete packaged runtime: $runtime" >&2; exit 1; }

rm -rf -- "$profile" "$work"
cp -a /usr/share/archiso/configs/releng "$profile"
release="$profile/airootfs/opt/forge/releases/$FORGE_RUNTIME_ID"
install -d "$release" "$profile/airootfs/opt/forge-os" "$profile/airootfs/usr/local/bin" "$profile/airootfs/usr/local/libexec" "$profile/airootfs/etc/greetd" "$profile/airootfs/usr/share/xsessions"
cp -a "$runtime/." "$release/"
ln -s "releases/$FORGE_RUNTIME_ID" "$profile/airootfs/opt/forge/current"
install -m 4755 "$runtime/chrome-sandbox" "$release/chrome-sandbox"
install -m 0755 "$root/session/forge-xsession" "$profile/airootfs/usr/local/bin/forge-xsession"
install -m 0755 "$root/session/forge-session" "$profile/airootfs/usr/local/bin/forge-session"
install -m 0755 "$root/session/forge-session-client" "$profile/airootfs/usr/local/libexec/forge-session-client"
install -m 0644 "$root/session/forge.desktop" "$profile/airootfs/usr/share/xsessions/forge.desktop"
install -m 0644 "$root/config/greetd-config.toml" "$profile/airootfs/etc/greetd/config.toml"
install -m 0644 "$record" "$release/.forge-runtime.env"
install -m 0644 "$root/VERSION" "$profile/airootfs/etc/forge-os-version"
git -C "$root" archive HEAD | tar -x -C "$profile/airootfs/opt/forge-os"

sed -i 's/^iso_name=.*/iso_name="forge-os"/' "$profile/profiledef.sh"
sed -i 's/^iso_label=.*/iso_label="FORGE_OS"/' "$profile/profiledef.sh"
while IFS= read -r package; do grep -qxF "$package" "$profile/packages.x86_64" || printf '%s\n' "$package" >>"$profile/packages.x86_64"; done < <(sed -e 's/#.*$//' -e '/^[[:space:]]*$/d' "$root/manifests/arch-packages.txt")
install -d "$profile/airootfs/etc/systemd/system/graphical.target.wants" "$profile/airootfs/etc/systemd/system/getty.target.wants"
ln -sf /usr/lib/systemd/system/greetd.service "$profile/airootfs/etc/systemd/system/graphical.target.wants/greetd.service"
ln -sf /usr/lib/systemd/system/getty@.service "$profile/airootfs/etc/systemd/system/getty.target.wants/getty@tty2.service"
ln -sf /usr/lib/systemd/system/graphical.target "$profile/airootfs/etc/systemd/system/default.target"

mkdir -p "$out"
sudo mkarchiso -v -w "$work" -o "$out" "$profile"
sha256sum "$out"/*.iso | tee "$out/SHA256SUMS"
