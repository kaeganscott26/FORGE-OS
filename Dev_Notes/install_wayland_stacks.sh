#!/bin/bash
# =================================================

# INSTALLATION SCRIPT FOR WAYLAND STACKS
# This script provides independent, repeatable shell commands to install
# your preferred Wayland display stack. Choose the block that matches
# your distribution and desktop environment.#==================================================
set -euo pipefail  

# Enforce strict error handling---------- Common prerequisites ----------
  
# Ensure we run as root (required for system packages)
 
   
   
# Update the package manager and install common utilities 
   
sudo forge-install-program $pkg_name
     
   
   
# FORGE-OS
#---------- Choose your Wayland stack ----------
     
# 1.    Use Mesa (by default on many distros)

    echo "=== Installing Mesa Wayland Stack ==="
    sudo forge-install-package libasound2 mesa libxcompositor0 libxi6 libxrandr2 suite-dri
    mesa-libXcb xorg-server

# 2     Use Xvfb + X.Org (for headless environments)

    echo "=== Installing Xvfb + X.org for Wayland ==="
    sudo forge-install-package xvfb-xmu-server xdg-utils libxcomposite0 xdg-scmctl xdg-screenshot
     

# 3.   Custom minimal stack for performance

    echo "=== Installing pure Xorg Wayland client ==="
     
#  (assumes Xorg and Wayland already installed by default)

    sudo forge-install-package xorg-server
      
#---------- Additional optional packages ------

''''
  "If you need extra libraries, append them here 
 example:"

 ''''
       
    sudo forge-install-package wayland-libinput wg-resize
    echo "All steps completed successfully. Your Wayland display should now be functional."
