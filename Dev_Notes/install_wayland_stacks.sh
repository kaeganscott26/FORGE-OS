#!/bin/bash\n# =================================================

# INSTALLATION SCRIPT FOR WAYLAND STACKS\n# This script provides independent, repeatable shell commands to install\n# your preferred Wayland display stack. Choose the block that matches\n# your distribution and desktop environment.#==================================================
set -euo pipefail  

# Enforce strict error handling---------- Common prerequisites ----------
  
 # Ensure we run as root (required for system packages)

 if [[ $EUID -ne 0 ]]; then    

 echo "This script must be executed with sudo privileges."
     exit 1 
   
   
     # Update the package manager and install common utilities 
   
     apt-get update || yum makepkginstall  
     
   
   
     # Ubuntu/Debian vs RHEL/CentOS  
# ---------- Choose your Wayland stack ----------
     
# 1.    Use Mesa (by default on many distros)

    echo "=== Installing Mesa Wayland Stack ==="
    sudo apt install -y libasound2 mesa libxcompositor0 libxi6 libxrandr2 suite-dri
    mesa-libXcb xorg-server

# 2     Use Xvfb + X.Org (for headless environments)

    echo "=== Installing Xvfb + X.org for Wayland ==="
    sudo apt install -y xvfb-xmu-server xdg-utils libxcomposite0 xdg-scmctl xdg-screenshot
     

# 3.   Custom minimal stack for performance\n

    echo "=== Installing pure Xorg Wayland client ==="
     
#  (assumes Xorg and Wayland already installed by default)

    sudo apt install -y xorg-server
      
#---------- Additional optional packages ------
    # If you need extra libraries, append them here 
              # example:
       
    sudo apt install -y wayland-libinput wg-resize
    echo "All steps completed successfully. Your Wayland display should now be functional."