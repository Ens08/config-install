#!/usr/bin/env bash
#===============================================================================
# Réinstall Tools – Script d'installation automatique pour Ubuntu
#===============================================================================

set -euo pipefail
IFS=$'\n\t'

# Vérifie que le script est lancé en root
if [[ $EUID -ne 0 ]]; then
  echo "Ce script doit être exécuté en tant que root (sudo)." >&2
  exit 1
fi

echo "======================================="
echo "  Mise à jour du système et upgrade"
echo "======================================="
apt update
apt -y upgrade

echo
echo "======================================="
echo "  Installation des paquets essentiels"
echo "======================================="
apt install -y \
    build-essential gcc g++ make cmake ninja-build \
    autoconf automake flex bison pkg-config libssl-dev \
    gdb valgrind strace ltrace \
    htop atop iotop sysstat \
    tcpdump nmap net-tools iproute2 socat lsof \
    git curl wget vim neovim tmux screen \
    software-properties-common apt-transport-https ca-certificates gnupg snapd \
    golang-go \
    nasm yasm binutils

echo
echo "======================================="
echo "  Installation de PHP et Composer"
echo "======================================="
apt install -y php php-cli php-common php-xml php-mbstring php-curl

if ! command -v composer &> /dev/null; then
  EXPECTED_SIG=$(curl -sS https://composer.github.io/installer.sig)
  php -r "copy('https://getcomposer.org/installer', 'composer-setup.php');"
  ACTUAL_SIG=$(php -r "echo hash_file('sha384', 'composer-setup.php');")

  if [ "$EXPECTED_SIG" != "$ACTUAL_SIG" ]; then
    >&2 echo 'Erreur : la signature de Composer ne correspond pas'
    rm composer-setup.php
    exit 1
  fi

  php composer-setup.php --install-dir=/usr/local/bin --filename=composer
  rm composer-setup.php
else
  echo "Composer déjà installé, mise à jour..."
  composer self-update
fi

echo
echo "======================================="
echo "  Installation de Visual Studio Code"
echo "======================================="
if ! command -v code &> /dev/null; then
  snap install --classic code
else
  echo "Visual Studio Code déjà installé via Snap"
fi

echo
echo "======================================="
echo "  Nettoyage final"
echo "======================================="
apt -y autoremove
apt -y autoclean

echo
echo "======================================="
echo "  Terminé !"
echo "======================================="
