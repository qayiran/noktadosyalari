#!/bin/bash

# Hıh, bir şeyleri bozmuşsundur diye jq kontrolü yapıyorum
if ! command -v jq &> /dev/null; then
    echo "Hata: 'jq' eksik, baka! Şununla kur: sudo pacman -S jq"
    exit 1
fi

# 1. Şu an çalışan çekirdek
CURRENT=$(uname -r)

# 2. Arch Linux 'core' deposundaki en son çekirdek
CORE=$(curl -sf https://archlinux.org/packages/core/x86_64/linux/json/ | jq -r '.pkgver + "-" + .pkgrel')

# 3. Arch Linux 'core-testing' deposundaki en son çekirdek
TESTING=$(curl -sf https://archlinux.org/packages/core-testing/x86_64/linux/json/ | jq -r '.pkgver + "-" + .pkgrel')
if [ -z "$TESTING" ] || [ "$TESTING" = "null-null" ]; then
    TESTING="Şu an test edilen yok"
fi

# 4. Kernel.org sürümleri
MAINLINE=$(curl -sf https://www.kernel.org/releases.json | jq -r '.releases[] | select(.moniker == "mainline") | .version')
LATEST_STABLE=$(curl -sf https://www.kernel.org/releases.json | jq -r '.releases[] | select(.moniker == "stable") | .version' | head -n 1)

# Çıktıyı anında göster (Manuel hizalama ile düzeltildi!)
echo ""
echo "=========================================="
echo "          Çekirdek Sürüm Durumu           "
echo "=========================================="
echo "Şu An Çalışan             | $CURRENT"
echo "Arch Linux (core)         | ${CORE:-Getirme hatası}"
echo "Arch Linux (core-testing) | $TESTING"
echo "En Son Kararlı Sürüm      | ${LATEST_STABLE:-Getirme hatası}"
echo "Ana Akım Sürüm (Linus)    | ${MAINLINE:-Getirme hatası}"
echo "=========================================="
