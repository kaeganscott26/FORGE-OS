#!/usr/bin/env bash
set -euo pipefail

root="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
record="$root/build/latest.env"
[[ -r "$record" ]] || { echo 'Run scripts/build-forge.sh first.' >&2; exit 1; }
source "$record"
for name in FORGE_SOURCE_COMMIT FORGE_VERSION FORGE_PACKAGE_SHA256 FORGE_LOCK_SHA256 FORGE_OS_VERSION FORGE_OS_COMMIT FORGE_OS_OVERLAY_SHA256 FORGE_RUNTIME_RELATIVE_PATH FORGE_EXECUTABLE_RELATIVE_PATH FORGE_EXECUTABLE_SHA256 FORGE_APP_ASAR_SHA256 FORGE_PAYLOAD_SHA256 FORGE_RUNTIME_ID; do
  [[ -n "${!name:-}" ]] || { echo "Missing $name in $record" >&2; exit 1; }
done
overlay_hash() {
  local overlay relative
  while IFS= read -r overlay; do
    relative="${overlay#"$root/"}"
    printf 'FILE %s\n' "$relative"
    sha256sum "$overlay" | awk '{print $1}'
  done < <(find "$root/overlays" -maxdepth 1 -type f -name '*.patch' -print | sort)
}
payload_hash() { (cd "$1"; { find . -type f ! -name .forge-runtime.env -print0 | sort -z | xargs -0 sha256sum; find . -type l -printf 'LINK %p %l\n' | LC_ALL=C sort; }) | sha256sum | awk '{print $1}'; }
[[ "$FORGE_OS_VERSION" == "$(<"$root/VERSION")" ]] || { echo 'Build record FORGE-OS version mismatch.' >&2; exit 1; }
[[ "$FORGE_OS_COMMIT" == "$(git -C "$root" rev-parse HEAD)" ]] || { echo 'Build record FORGE-OS commit mismatch.' >&2; exit 1; }
[[ "$FORGE_OS_OVERLAY_SHA256" == "$(overlay_hash | sha256sum | awk '{print $1}')" ]] || { echo 'Build record overlay hash mismatch.' >&2; exit 1; }
runtime="$root/$FORGE_RUNTIME_RELATIVE_PATH"
runtime_exec="$runtime/$FORGE_EXECUTABLE_RELATIVE_PATH"
work="$root/build/archiso-work"
out="$root/build/iso"
profile="$root/build/archiso-profile"
command -v mkarchiso >/dev/null || { echo 'Install archiso first.' >&2; exit 1; }
[[ -x "$runtime_exec" && -r "$runtime/resources/app.asar" ]] || { echo "Incomplete packaged runtime: $runtime" >&2; exit 1; }
[[ "$(sha256sum "$runtime_exec" | awk '{print $1}')" == "$FORGE_EXECUTABLE_SHA256" ]] || { echo 'Packaged executable hash mismatch.' >&2; exit 1; }
[[ "$(sha256sum "$runtime/resources/app.asar" | awk '{print $1}')" == "$FORGE_APP_ASAR_SHA256" ]] || { echo 'Packaged app.asar hash mismatch.' >&2; exit 1; }
[[ "$(payload_hash "$runtime")" == "$FORGE_PAYLOAD_SHA256" ]] || { echo 'Packaged runtime payload hash mismatch.' >&2; exit 1; }

rm -rf -- "$profile" "$work"
cp -a /usr/share/archiso/configs/releng "$profile"
release="$profile/airootfs/opt/forge/releases/$FORGE_RUNTIME_ID"
install -d \
  "$release" \
  "$profile/airootfs/opt/forge-os" \
  "$profile/airootfs/usr/local/bin" \
  "$profile/airootfs/usr/local/libexec" \
  "$profile/airootfs/etc/xdg" \
  "$profile/airootfs/usr/share/applications" \
  "$profile/airootfs/usr/share/xdg-desktop-portal" \
  "$profile/airootfs/etc/greetd" \
  "$profile/airootfs/usr/share/forge-os/xsessions" \
  "$profile/airootfs/usr/share/forge-os/wayland-sessions" \
  "$profile/airootfs/etc/systemd/system/graphical.target.wants" \
  "$profile/airootfs/etc/systemd/system/getty.target.wants" \
  "$profile/airootfs/etc/systemd/system/multi-user.target.wants"
cp -a "$runtime/." "$release/"
ln -s "releases/$FORGE_RUNTIME_ID" "$profile/airootfs/opt/forge/current"
install -m 4755 "$runtime/chrome-sandbox" "$release/chrome-sandbox"
install -m 0755 "$root/session/forge-xsession" "$profile/airootfs/usr/local/bin/forge-xsession"
install -m 0755 "$root/session/forge-session" "$profile/airootfs/usr/local/bin/forge-session"
install -m 0755 "$root/session/forge-session-client" "$profile/airootfs/usr/local/libexec/forge-session-client"
for tool in forge-app-launcher forge-open forge-workspace-runner forge-install-program; do
  install -m 0755 "$root/scripts/$tool" "$profile/airootfs/usr/local/bin/$tool"
done
install -m 0644 "$root/config/kwinrc" "$profile/airootfs/etc/xdg/kwinrc"
install -m 0644 "$root/config/kdeglobals" "$profile/airootfs/etc/xdg/kdeglobals"
install -m 0644 "$root/config/forge-portals.conf" "$profile/airootfs/usr/share/xdg-desktop-portal/forge-portals.conf"
for desktop in forge-app-launcher.desktop forge-system-settings.desktop forge-workspace-runner.desktop forge-install-program.desktop; do
  install -m 0644 "$root/session/$desktop" "$profile/airootfs/usr/share/applications/$desktop"
done
install -m 0644 "$root/session/forge.desktop" "$profile/airootfs/usr/share/forge-os/xsessions/forge.desktop"
install -m 0644 "$root/config/greetd-config.toml" "$profile/airootfs/etc/greetd/config.toml"
install -m 0644 "$record" "$release/.forge-runtime.env"
install -m 0644 "$root/VERSION" "$profile/airootfs/etc/forge-os-version"
sed -e "s/@VERSION@/$(<"$root/VERSION")/g" -e "s/@SOURCE_COMMIT@/${FORGE_SOURCE_COMMIT:0:12}/g" "$root/config/issue" >"$profile/airootfs/etc/issue"
git -C "$root" archive HEAD | tar -x -C "$profile/airootfs/opt/forge-os"

sed -i 's/^iso_name=.*/iso_name="forge-os"/' "$profile/profiledef.sh"
sed -i 's/^iso_label=.*/iso_label="FORGE_OS"/' "$profile/profiledef.sh"
while IFS= read -r package; do
  grep -qxF "$package" "$profile/packages.x86_64" || printf '%s\n' "$package" >>"$profile/packages.x86_64"
done < <(sed -e 's/#.*$//' -e '/^[[:space:]]*$/d' "$root/manifests/arch-packages.txt")

ln -sf /usr/lib/systemd/system/greetd.service "$profile/airootfs/etc/systemd/system/graphical.target.wants/greetd.service"
ln -sf /usr/lib/systemd/system/greetd.service "$profile/airootfs/etc/systemd/system/display-manager.service"
ln -sf /usr/lib/systemd/system/getty@.service "$profile/airootfs/etc/systemd/system/getty.target.wants/getty@tty2.service"
for service in NetworkManager.service bluetooth.service irqbalance.service power-profiles-daemon.service; do
  ln -sf "/usr/lib/systemd/system/$service" "$profile/airootfs/etc/systemd/system/multi-user.target.wants/$service"
done
ln -sf /usr/lib/systemd/system/graphical.target "$profile/airootfs/etc/systemd/system/default.target"

sudo chown root:root "$release/chrome-sandbox"
sudo chmod 4755 "$release/chrome-sandbox"
mkdir -p "$out"
sudo mkarchiso -v -w "$work" -o "$out" "$profile"
sha256sum "$out"/*.iso | tee "$out/SHA256SUMS"
echo "Built FORGE-OS ISO from FORGE $FORGE_SOURCE_COMMIT runtime $FORGE_RUNTIME_ID"
