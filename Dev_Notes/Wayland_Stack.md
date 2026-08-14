1. The Core Wayland & Desktop StackFirst, replace your X11/XFCE layers with the base Plasma desktop components and the native Wayland compositor (kwin).plasma-desktop (The core desktop environment)kwin (The window manager/Wayland compositor)wayland (The display protocol)xorg-xwayland (For compatibility running older X11 apps seamlessly)sddm (The display/login manager used by Garuda)

2. XDG Portals (Crucial for Wayland)To ensure that screensharing, file dialogs, and permissions work smoothly under Wayland, you must configure your XDG backend:xdg-desktop-portalxdg-desktop-portal-kde

3. The Visual Engine (The "Dr460nized" Look)Garuda's aesthetics rely heavily on a specific Qt/GTK blur engine and specific themes. To get this layout on vanilla Arch, install:kvantum (The SVG-based theme engine responsible for the translucent UI)plasma-applet-window-buttons (An applet that moves window controls to the top panel, Mac-style)kde-gtk-config (Syncs your dark/neon themes over to GTK applications)

4. Downstream Garuda Themes (Optional AUR)Garuda packages their exact visual layouts into the AUR. If you want their actual styling presets without writing the CSS yourself, you can pull these from the AUR using an AUR helper:sweet-gtk-theme-git (The primary neon/dark theme)beautyline (The default neon icon pack)garuda-dr460nized (The meta-package containing their exact layout configurations)

5. Essential System UtilitiesGaruda keeps the underlying OS snappy by utilizing specific low-latency blocks instead of standard Arch defaults:linux-zen (The kernel Garuda uses by default, optimized for desktop responsiveness)dolphin (The native KDE file manager)✅ Summary of the StackTo match Garuda's environment, you are transitioning to a KDE Plasma Wayland architecture driven by kwin, styled via kvantum, and bridged using xdg-desktop-portal-kde.

==========================================================
----------------Hyprland_Style_Environment----------------
==========================================================

To use Hyprland as the foundational window manager while embedding your own custom program as the primary user-facing interface, you are essentially building a bespoke desktop environment (DE). Since Arch is meant to act as an invisible backend, you need a precise, minimal Wayland toolchain that handles app windowing, styling consistency, and assets like backgrounds without pulling in massive desktop suites.Here is the decoupled backend stack and configuration workflow required to build this environment.

1. Core Hyprland & Invisible System LayerThis is the bare-minimum layer required to render application windows smoothly via Wayland and route them to your custom interface program.hyprland: The dynamic tiling Wayland compositor. It serves as your display server and window management engine.xdg-desktop-portal-hyprland: Mandatory for file pickers, screensharing, and standard app communication protocols under Hyprland.xorg-xwayland: Bridges older X11-only applications over to your Wayland ecosystem transparently.seatd or systemd-logind: Handles rootless session management silently in the background.

2. The Custom Interface & Wallpaper LayerBecause you are running a custom program as the shell, you need independent background engines that your program can trigger or communicate with via command-line flags or standard APIs.hyprpaper or swww: Lightning-fast, scriptable Wayland wallpaper daemons.Why this works for you: Your custom user-facing app can change the desktop background on the fly simply by executing a background system call like: hyprpaper wallpaper "Monitor, /path/to/image.png".waybar (Optional): If your user-facing program does not already handle system status readouts (battery, Wi-Fi, clock), this is the highly customizable, CSS-driven status panel used by Garuda Hyprland.

3. Unified Theme Engine (GTK & Qt App Polishing)To ensure that standard Linux apps (like browsers or file managers) look polished and uniform instead of rendering with broken, ugly fallback skins, you must force a unified theme engine across both major UI toolkits.For GTK Apps (Gnome/Flatpak style)gsettings (part of glib2): Used to programmatically force themes onto GTK applications without needing a graphical control panel.Polishing Command: Your custom environment can run this setup script in the background on launch to instantly force a uniform dark layout:bashgsettings set org.gnome.desktop.interface gtk-theme "Your-Theme-Name"
gsettings set org.gnome.desktop.interface icon-theme "Your-Icon-Name"
gsettings set org.gnome.desktop.interface color-scheme "prefer-dark"
Use code with caution.For Qt Apps (KDE/Next-Gen style)qt6-wayland & qt5-wayland: Required to make Qt applications render natively under Hyprland rather than crashing or lagging.kvantum: The theme engine engine.Polishing Environment Variables: To keep Arch invisible, append these specific variables to your system environment (e.g., /etc/environment or your user profile) to force Qt apps to mimic your GTK styling rules automatically:bashQT_QPA_PLATFORM="wayland;xcb"
QT_QPA_PLATFORMTHEME="qt6ct"
Use code with caution.

4. Directing Hyprland to Launch Your Custom ShellTo keep the backend completely hidden, configure Hyprland to boot straight into your custom app. Modify your local Hyprland configuration file (~/.config/hypr/hyprland.conf) to automate the styling daemons and launch your user interface:ini# ~/.config/hypr/hyprland.conf

# 1. Start the wallpaper daemon silently
exec-once = hyprpaper

# 2. Force system theme configuration on launch
exec-once = gsettings set org.gnome.desktop.interface gtk-theme 'Sweet-Ambar-Blue'

# 3. Launch your custom user-facing program as the desktop shell
exec-once = /path/to/your/custom/interface-program
Use code with caution.What language or framework is your custom user-facing environment built with, and would you like example scripts showing how to programmatically change themes or wallpapers directly from your application's code?


## FORGE_OS Executable (Resolved)

The login screen previously defaulted to the incorrect location `/usr/bin/openbox-session`.

This is not a supported direct login command.

FORGE-OS now uses the required default launch command:

```bash
/usr/bin/xinit /usr/local/libexec/forge-session-client
```

The Plasma and Hyprland sections above began as architecture research. X11 + Openbox was the verified baseline beneath FORGE; a native Wayland migration still requires separate design and physical validation.

As of `0.1.2-alpha`, the first migration slice uses Plasma 6 KWin X11 for Hyprland-inspired windowing and Breeze/Kvantum styling while preserving Openbox as an automatic fallback. This deliberately does not change the verified X11 boot/login command or start a second Plasma desktop shell.

## REPO DOCUMENTATION and Scripts

After every task that changes or adds updates to FORGE or FORGE-OS, all repo documentation must be updated and must be consistent across HEADERS, scripts, documentation, notes, etc. All updates must be comipiled into the next version number..example 2.3.0-beta.1 => 2.3.1-beta.1 => 2.3.2-beta.1 etc. Only change 2.3 => 2.4 if it is a major architectur updgrade, or released as a stable production build, or the last version worked on was 2.3.9-beta.1.

## CHANGELOG
ALL CHANGES MUST BE RECORDED INTO THE CHANGELOG.
