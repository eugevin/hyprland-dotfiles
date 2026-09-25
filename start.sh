#!/bin/bash
set -e

echo "--- Starting System Setup ---"

echo "Updating and upgrading the system..."
sudo pacman -Syu

echo "Installing dependencies..."
sudo pacman -S --needed git less base-devel

echo "Installing core components..."
sudo pacman -S --needed firefox kitty ghostty dolphin \
  hyprland hyprpolkitagent hyprpaper quickshell rofi xdg-desktop-portal-hyprland wl-clipboard \
  pipewire wireplumber pipewire-pulse pavucontrol \
  grim slurp \
  mpv gwenview \
  ttf-iosevka-nerd otf-font-awesome noto-fonts-cjk

echo "Configuring audio services..."
systemctl --user enable --now pipewire.service pipewire-pulse.service wireplumber.service

echo "Cloning dotfiles from GitHub..."
git clone https://github.com/eugevin/hyprland-dotfiles.git ~/.dotfiles

echo "Linking configurations..."
rm -rf ~/.config/hypr && ln -sf ~/.dotfiles/hypr ~/.config/hypr
rm -rf ~/.config/rofi && ln -sf ~/.dotfiles/rofi ~/.config/rofi
rm -rf ~/.config/quickshell && ln -sf ~/.dotfiles/quickshell ~/.config/quickshell
