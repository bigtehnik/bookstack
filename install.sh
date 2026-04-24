#!/bin/bash

# Выход при любой ошибке
set -e

# Проверка, что скрипт запущен от root
if [ "$EUID" -ne 0 ]; then
  echo "Пожалуйста, запустите этот скрипт от имени root (sudo)."
  exit 1
fi

echo "### Шаг 1: Ставим Node.js 22 ###"

# Установка curl и gnupg, если их нет
apt-get update
apt-get install -y curl gnupg

# Добавление репозитория NodeSource и установка Node.js
curl -fsSL https://deb.nodesource.com/setup_22.x | bash -
apt-get install -y nodejs

# Проверка установки Node.js
echo "Установленная версия Node.js:"
node --version

echo -e "\n### Шаг 2: Настройка глобальной npm директории ###"

# Создание директории
mkdir -p /root/.npm-global

# Конфигурация npm
npm config set prefix '/root/.npm-global'

# Добавление пути в .bashrc (для будущих сессий)
if ! grep -q "export PATH=/root/.npm-global/bin:\$PATH" ~/.bashrc; then
    echo 'export PATH=/root/.npm-global/bin:$PATH' >> ~/.bashrc
    echo "Путь добавлен в ~/.bashrc"
else
    echo "Путь уже присутствует в ~/.bashrc"
fi

# Применение пути для текущей сессии
export PATH=/root/.npm-global/bin:$PATH

echo -e "\n### Шаг 3: Установка OpenClaw и проверка версии ###"

# Если OpenClaw уже установлен, удаляем старую версию
if [ -d "/root/.npm-global/lib/node_modules/openclaw" ]; then
    echo "Старая версия OpenClaw найдена, удаляем..."
    rm -rf /root/.npm-global/lib/node_modules/openclaw
fi

# Очистка кеша npm
npm cache clean --force

# Установка последней версии OpenClaw
npm install -g openclaw@2026.4.22

# Проверка версии
echo "Проверка версии OpenClaw:"
openclaw --version

echo -e "\n### Установка успешно завершена! выполняем команду openclaw onboard ###"

