#!/bin/bash

# Выход при ошибке
set -e

# Проверка, запущен ли скрипт от root
if [ "$EUID" -ne 0 ]; then
  echo "Пожалуйста, запустите этот скрипт от имени root (sudo)."
  exit
fi

echo "### Шаг 1: Ставим  Node.js 22 ###"

# Установка curl, если его нет
apt-get update
apt-get install -y curl

# Добавление репозитория NodeSource и установка
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

# Применение пути для текущей сессии скрипта
export PATH=/root/.npm-global/bin:$PATH

echo -e "\n### Шаг 3: Установка OpenClaw и проверка версии ###"

npm install -g openclaw@latest

echo "Проверка версии OpenClaw:"
openclaw --version

echo -e "\n### Установка успешно завершена! ###"
echo "Примечание: Чтобы команда 'openclaw' была доступна в новом терминале, перезапустите сессию или выполните: source ~/.bashrc"
