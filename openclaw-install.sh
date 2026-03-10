#!/usr/bin/env bash
set -e

echo "======================================"
echo "     OpenClaw Installer (PNPM)        "
echo "======================================"

if [ "$EUID" -ne 0 ]; then
  echo "❌ Запусти скрипт от root"
  exit 1
fi

echo "=== Установка Node.js 22 ==="
curl -fsSL https://deb.nodesource.com/setup_22.x | bash -
apt install -y nodejs

echo "=== Установка pnpm ==="
npm install -g pnpm

echo "=== Настройка глобальной npm директории ==="
mkdir -p /root/.npm-global
npm config set prefix '/root/.npm-global'
echo 'export PATH=/root/.npm-global/bin:$PATH' >> /root/.bashrc
echo 'export PATH=/root/.npm-global/bin:$PATH' > /etc/profile.d/npm-global.sh
chmod +x /etc/profile.d/npm-global.sh
export PATH=/root/.npm-global/bin:$PATH

echo "=== Очистка старых установок OpenClaw ==="
rm -rf /root/.npm-global/lib/node_modules/openclaw || true
rm -rf /root/.npm-global/lib/node_modules/.openclaw-* || true

echo "=== Установка OpenClaw через pnpm ==="
pnpm add -g openclaw@latest

echo "=== Проверка версии OpenClaw ==="
openclaw --version

echo "=== Инициализация OpenClaw ==="
openclaw onboard

echo "======================================"
echo "   Установка OpenClaw завершена!       "
echo "======================================"
