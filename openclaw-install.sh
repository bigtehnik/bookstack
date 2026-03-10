#!/usr/bin/env bash
set -e

echo "=== Установка Node.js 22 ==="
curl -fsSL https://deb.nodesource.com/setup_22.x | bash -
apt install -y nodejs

echo "=== Настройка глобальной npm директории ==="
mkdir -p /root/.npm-global
npm config set prefix '/root/.npm-global'

if ! grep -q "/root/.npm-global/bin" ~/.bashrc; then
  echo 'export PATH=/root/.npm-global/bin:$PATH' >> ~/.bashrc
fi

source ~/.bashrc

echo "=== Установка OpenClaw ==="
npm install -g openclaw@latest

echo "=== Проверка версии OpenClaw ==="
openclaw --version

echo "=== Инициализация OpenClaw ==="
openclaw onboard

echo "=== Установка завершена ==="
