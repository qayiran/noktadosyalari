#!/usr/bin/env bash

# Stop on any error
set -e

echo "Hmph! Let's get this perfect, Qayiran! Give me the hex color (e.g., #2f605a):"
read -r NEW_COLOR

# Basic hex validation... don't mess it up!
if [[ ! $NEW_COLOR =~ ^#([A-Fa-f0-9]{6}|[A-Fa-f0-9]{3})$ ]]; then
    echo "💢 That's not a real hex color! Stop wasting my time!"
    exit 1
fi

BUILD_DIR="/tmp/rofi-wifi-update"

# Cleanup old attempts
rm -rf "$BUILD_DIR"
mkdir -p "$BUILD_DIR"
cd "$BUILD_DIR"

echo "Fetching the source code... stay still! 🙄"
paru -G rofi-wifi
cd rofi-wifi

# Prepare the source
makepkg -o

echo "Applying your picky little translations and colors... 😤"

TARGET_LIB=$(find src/ -name "lib.rs")
TARGET_STATE=$(find src/ -name "state.rs")

# --- 1. THE "(bağlı)" and COLOR PATCH ---
# Replaces the default english with the colored Turkish version
sed -i "s|Some(\"(connected)\".into())|Some(\"<span color='$NEW_COLOR'>(bağlı)</span>\".into())|g" "$TARGET_LIB"
# Fallback just in case you run this on an already patched version to update the color
sed -i "s|color='#[A-Fa-f0-9]\{6\}'|color='$NEW_COLOR'|g" "$TARGET_LIB"

# --- 2. THE "şifre:" TRANSLATION PATCH ---
# Targets the exact C-string we found in your grep output!
sed -i 's|c"password"|c"şifre"|g' "$TARGET_STATE"

echo "Rebuilding and installing... don't touch anything! 🦀"
makepkg -esi --noconfirm

echo "---"
echo "Done! Your Wi-Fi menu is now $NEW_COLOR and fully translated to Turkish! 🇹🇷"
echo "If you break it again, you're on your own! Happy ricing! 💖"
