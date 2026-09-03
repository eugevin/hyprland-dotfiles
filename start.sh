#!/bin/bash
set -e

echo "--- Starting System Setup ---"

echo "Updating system and installing dependencies..."
sudo pacman -Syu --needed git less base-devel

echo "Installing core components..."
sudo pacman -S --needed firefox kitty ghostty dolphin \
	hyprland hyprpolkitagent hyprpaper dunst rofi xdg-desktop-portal-hyprland waybar wl-clipboard \
	pipewire wireplumber pipewire-pulse pavucontrol \
	grim slurp \
	ttf-jetbrains-mono ttf-jetbrains-mono-nerd otf-font-awesome noto-fonts-cjk

echo "Configuring audio services..."
systemctl --user enable --now pipewire.service pipewire-pulse.service wireplumber.service

echo "Cloning dotfiles from GitHub..."
git clone https://github.com/eugevin/hyprland-dotfiles.git ~/.dotfiles

echo "Linking configurations..."
rm -rf ~/.config/hypr && ln -sf ~/.dotfiles/hypr ~/.config/hypr
rm -rf ~/.config/waybar && ln -sf ~/.dotfiles/waybar ~/.config/waybar
rm -rf ~/.config/rofi && ln -sf ~/.dotfiles/rofi ~/.config/rofi
rm -rf ~/.config/dunst && ln -sf ~/.dotfiles/dunst ~/.config/dunst
