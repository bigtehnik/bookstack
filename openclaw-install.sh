#!/usr/bin/env bash
set -e

echo "======================================"
echo "     OpenClaw Installer (Root)        "
echo "======================================"

# Проверка root
if [ "$EUID" -ne 0 ]; then
  echo "❌ Запусти скрипт от root"
  exit 1
fi

echo "=== Проверка наличия swap ==="
if ! swapon --show | grep -q "swapfile"; then
  echo "=== Swap не найден. Создаю 2G swap ==="
  fallocate -l 2G /swapfile
  chmod 600 /swapfile
  mkswap /swapfile
  swapon /swapfile
  echo '/swapfile none swap sw 0 0' >> /etc/fstab
else
  echo "=== Swap уже существует ==="
fi

echo "=== Установка Node.js 22 ==="
curl -fsSL https://deb.nodesource.com/setup_22.x | bash -
apt install -y nodejs

echo "=== Настройка глобальной npm директории ==="
mkdir -p /root/.npm-global
npm config set prefix '/root/.npm-global'

echo 'export PATH=/root/.npm-global/bin:$PATH' >> /root/.bashrc
echo 'export PATH=/root/.npm-global/bin:$PATH' > /etc/profile.d/npm-global.sh
chmod +x /etc/profile.d/npm-global.sh

export PATH=/root/.npm-global/bin:$PATH

echo "=== Установка OpenClaw ==="
NODE_OPTIONS="--max-old-space-size=256" npm install -g openclaw@latest

echo "=== Проверка версии OpenClaw ==="
openclaw --version

echo "=== Инициализация OpenClaw ==="
openclaw onboard

echo "======================================"
echo "   Установка OpenClaw завершена!       "
echo "======================================"
