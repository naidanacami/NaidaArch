#!/usr/bin/env bash
pacman -S --noconfirm --needed lightdm lightdm-webkit2-greeter
systemctl enable lightdm
yay -S --noconfirm --needed lightdm-webkit-theme-aether 