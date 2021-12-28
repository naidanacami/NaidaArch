#!/usr/bin/env bash
PKGS=(
# Double
# _   _   ___   ____    ___ 
# \\ //  // \\  || \\  // \\
#  )X(  ((   )) ||_// (( ___
# // \\  \\_//  || \\  \\_||
'xorg-server'           # XOrg server
'xorg-apps'             # XOrg apps group
'xorg-xinit'            # XOrg init
'xf86-video-intel'      # 2D/3D video driver
'mesa'                  # Open source version of OpenGL
'xf86-input-libinput'   # Trackpad driver for Dell XPS


# __  __  ____ ______ __    __   ___   ____  __ __
# ||\ || ||    | || | ||    ||  // \\  || \\ || //
# ||\\|| ||==    ||   \\ /\ // ((   )) ||_// ||<< 
# || \|| ||___   ||    \V/\V/   \\_//  || \\ || \\
'wpa_supplicant'            # Key negotiation for WPA wireless networks
'dialog'                    # Enables shell scripts to trigger dialog boxex
'networkmanager'            # Network connection manager
'openvpn'                   # Open VPN support
'networkmanager-openvpn'    # Open VPN plugin for NM
'networkmanager-vpnc'       # Open VPN plugin for NM. Probably not needed if networkmanager-openvpn is installed.
'network-manager-applet'    # System tray icon/utility for network connectivity
'dhclient'                  # DHCP client
'libsecret'                 # Library for storing passwords


# ____  __    __ __  ____ ______   ___     ___   ______ __  __
# || )) ||    || || ||    | || |  // \\   // \\  | || | ||  ||
# ||=)  ||    || || ||==    ||   ((   )) ((   ))   ||   ||==||
# ||_)) ||__| \\_// ||___   ||    \\_//   \\_//    ||   ||  ||
'bluez'                 # Daemons for the bluetooth protocol stack
'bluez-utils'           # Bluetooth development and debugging utilities
'bluez-firmware'        # Firmwares for Broadcom BCM203x and STLC2300 Bluetooth chips
'blueberry'             # Bluetooth configuration tool
'pulseaudio-bluetooth'  # Bluetooth support for PulseAudio                                   


#  ___  __ __ ____   __   ___  
# // \\ || || || \\  ||  // \\ 
# ||=|| || || ||  )) || ((   ))
# || || \\_// ||_//  ||  \\_// 
'alsa-utils'        # Advanced Linux Sound Architecture (ALSA) Components https://alsa.opensrc.org/
'alsa-plugins'      # ALSA plugins
'pulseaudio'        # Pulse Audio sound components
'pulseaudio-alsa'   # ALSA configuration for pulse audio
'pavucontrol'       # Pulse Audio volume control
'volumeicon'        # System tray volume control


# ___  ___ __  __    ___
# ||\\//|| || (( \  //  
# || \/ || ||  \\  ((   
# ||    || || \_))  \\__
# Communication
'discord'

# Development
'nano'
'code'
'neovim'
'git'                   # Version control system
'python3'
'base-devel'

# Office
'libreoffice-fresh'

# Browsers
'firefox'
'brave'

# Themes
'materia-kde'
'papirus-icon-theme'

# Terminal
'alacritty'

# Filemanager
# 'pcmanfm'
'thunar'
'ranger'

# Gaming
'steam'
'lutris' # gaming platform
# 'gamemode' # gaming optimizations


# Media
'vlc'                   # Video player

# Terminal utilities
'btop'                  # System monitoring via terminal
'bash-completion'       # Tab completion for Bash
'curl'                  # Remote content retrieval
'neofetch'              # Shows system info when you launch terminal
'openssh'               # SSH connectivity tools
'unrar'                 # RAR compression program
'unzip'                 # Zip compression program
'p7zip'                 # 7Z format support 
'zip'                   # Zip compression program
'pacman-contrib'        # scripts and tools for pacman systems


# Disk utilities
'autofs'                # Auto-mounter
'exfat-utils'           # Mount exFat drives
'ntfs-3g'               # Open source implementation of NTFS file system

# General utilities
'catfish'               # Filesystem search
'veracrypt'             # Disc encryption utility

# Other
'grub-customizer' # gui to customize grub
)

for PKG in "${PKGS[@]}"; do
    echo "INSTALLING ARCH DEFAULT PACKAGE: ${PKG}"
    pacman -S "$PKG" --noconfirm --needed
done