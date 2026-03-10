#!/usr/bin/env bash
set -e

echo "=== Установка Node.js 22 ==="
curl -fsSL https://deb.nodesource.com/setup_22.x | bash -
apt install -y nodejs

echo "=== Настройка глобальной npm директории ==="
mkdir -p /root/.npm-global
npm config set prefix '/root/.npm-global'

# Гарантированный PATH для всех оболочек
echo 'export PATH=/root/.npm-global/bin:$PATH' >> /root/.bashrc
echo 'export PATH=/root/.npm-global/bin:$PATH' > /etc/profile.d/npm-global.sh
chmod +x /etc/profile.d/npm-global.sh

# Гарантированный PATH в текущем процессе
export PATH=/root/.npm-global/bin:$PATH

echo "=== Установка OpenClaw ==="
npm install -g openclaw@latest

echo "=== Проверка версии OpenClaw ==="
if ! command -v openclaw >/dev/null 2>&1; then
  echo "❌ openclaw не найден в PATH"
  echo "PATH: $PATH"
  exit 1
fi

openclaw --version

echo "=== Инициализация OpenClaw ==="
openclaw onboard

echo "=== Установка завершена ==="
