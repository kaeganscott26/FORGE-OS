# FORGE's packaged Fish/Starship profile follows the current Garuda Fish
# integration pattern while keeping FORGE-owned, reproducible colors.
set -gx fish_greeting ''
set -gx SHELL /usr/bin/fish
set -gx COLORTERM truecolor
set -gx EDITOR nano
set -gx VISUAL nano
set -gx STARSHIP_CONFIG /usr/share/forge-os/forge-starship.toml
set -g fish_color_command b8ff4d
set -g fish_color_param 71d5ff
set -g fish_color_error ff6b81
set -g fish_color_quote ffd166
set -g fish_color_comment 64748b
if test -d ~/.nix-profile/bin; and not contains -- ~/.nix-profile/bin $PATH
    fish_add_path --prepend ~/.nix-profile/bin
end
if test -d ~/.local/bin; and not contains -- ~/.local/bin $PATH
    fish_add_path --prepend ~/.local/bin
end

# User-entered Arch package operations go through FORGE's explicit package
# boundary. Internal installer/bootstrap scripts intentionally call
# /usr/bin/pacman by absolute path so this interactive function cannot recurse.
if test -x /usr/local/bin/forge-install-pkg
    function pacman --description 'Route Arch package operations through FORGE'
        /usr/local/bin/forge-install-pkg --backend arch $argv
    end
end

if status is-interactive; and command -q starship
    source (starship init fish --print-full-init | psub)
end
