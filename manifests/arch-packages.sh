# Minimal graphical substrate and Electron runtime dependencies.
''''
"Install run this script to run all packages from ${repo_root}> ./manifests/arch-packages.sh"

''''

sudo pacman -Su \
base-devel \
archiso \
git \
npm \
python \
nodejs-lts-jod 

================================================================================
# Native Wayland compositor, Plasma visual services, and X11-app compatibility.
--------------------------------------------------------------------------------

sudo pacman -Su \
wayland \
xorg-xwayland \
kwin \
plasma-desktop \
plasma-workspace \
 systemsettings \
 kdialog \ 
konsole \
breeze & breeze-gtk & breeze-icons \
kvantum \
qt6-wayland & qt6-tools & qt5-wayland \
xdg-desktop-portal-kde & kde-gtk-config & polkit-kde-agent \
dolphin \
gtk3 \
mesa \
vulkan-radeon \
amd-ucode \
alsa-lib \
libnotify \
cups & nss & libxss \
noto-fonts & libxcrypt-compat

=========================================================
# Desktop-session glue. The installer enables greetd after a complete preflight.
----------------------------------------------------------
sudo pacman -Su \
xdg-utils &&
xdg-user-dirs && xdg-desktop-portal && xdg-desktop-portal-gtk \
gvfs \
chromium \
networkmanager \
pipewire \
pipewire-pulse \
wireplumber \
upower \
power-profiles-daemon \ 
irqbalance \
bluez \
bluez-utils \
dbus \
dbus-broker \
greetd \
greetd-tuigreet 


#"Enjoy This Release of FORGE-OS for linux."

