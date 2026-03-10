#!/usr/bin/env bash
set -e

echo "======================================"
echo "     OpenClaw Installer (Root)        "
echo "======================================"

if [ "$EUID" -ne 0 ]; then
  echo "❌ Запусти скрипт от root"
  exit 1
fi

echo "=== Создание 4G swap ==="
swapoff -a || true
rm -f /swapfile || true
fallocate -l 4G /swapfile
chmod 600 /swapfile
mkswap /swapfile
swapon /swapfile
echo '/swapfile none swap sw 0 0' > /etc/fstab

echo "=== Установка Node.js 22 ==="
curl -fsSL https://deb.nodesource.com/setup_22.x | bash -
apt install -y nodejs

echo "=== Настройка npm в low-memory режиме ==="
npm set fund false
npm set audit false
npm set progress false
npm set maxsockets 1
npm set jobs 1

echo "=== Настройка глобальной npm директории ==="
mkdir -p /root/.npm-global
npm config set prefix '/root/.npm-global'

echo 'export PATH=/root/.npm-global/bin:$PATH' >> /root/.bashrc
echo 'export PATH=/root/.npm-global/bin:$PATH' > /etc/profile.d/npm-global.sh
chmod +x /etc/profile.d/npm-global.sh
export PATH=/root/.npm-global/bin:$PATH

clean_openclaw() {
  rm -rf /root/.npm-global/lib/node_modules/openclaw || true
  rm -rf /root/.npm-global/lib/node_modules/.openclaw-* || true
}

echo "=== Очистка старых установок ==="
clean_openclaw

install_attempt() {
  NODE_OPTIONS="--max-old-space-size=128" \
  npm install -g openclaw@latest --no-optional --prefer-offline --foreground-scripts --unsafe-perm --loglevel=warn --no-audit --no-fund --no-progress --maxsockets=1 || return 1
}

echo "=== Установка OpenClaw (попытка 1) ==="
if ! install_attempt; then
  echo "⚠️ Попытка 1 не удалась"
  clean_openclaw
  echo "=== Установка OpenClaw (попытка 2) ==="
  if ! install_attempt; then
    echo "⚠️ Попытка 2 не удалась"
    clean_openclaw
    echo "=== Установка OpenClaw (попытка 3) ==="
    install_attempt
  fi
fi

echo "=== Проверка версии OpenClaw ==="
openclaw --version

echo "=== Инициализация OpenClaw ==="
openclaw onboard

echo "======================================"
echo "   Установка OpenClaw завершена!       "
echo "======================================"
