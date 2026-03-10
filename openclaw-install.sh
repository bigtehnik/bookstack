#!/bin/bash

# Скрипт установки Node.js 22, настройки npm и установки OpenClaw
# Запускать от имени root или с sudo

set -e  # Остановка при ошибке

echo "🚀 Начало установки..."

# 1. Установка Node.js 22
echo "📦 Установка Node.js 22..."
curl -fsSL https://deb.nodesource.com/setup_22.x | bash -
apt install -y nodejs

# 2. Настройка глобальной npm-директории
echo "⚙️ Настройка глобальной npm-директории..."
mkdir -p /root/.npm-global
npm config set prefix '/root/.npm-global'

# Добавление PATH в ~/.bashrc, если ещё не добавлено
if ! grep -q "/root/.npm-global/bin" ~/.bashrc; then
    echo 'export PATH=/root/.npm-global/bin:$PATH' >> ~/.bashrc
fi

# Применяем изменения в текущей сессии
export PATH=/root/.npm-global/bin:$PATH
source ~/.bashrc

# 3. Установка OpenClaw
echo "🔧 Установка OpenClaw..."
npm install -g openclaw@latest

# Проверка версии
echo "✅ Проверка версии OpenClaw:"
openclaw --version

# 4. Финальный этап — ожидание пользователя
echo ""
echo "🎉 Установка завершена!"
echo "👇 Для запуска онбординга нажмите ENTER, затем выполните команду вручную:"
echo ""
echo "   openclaw onboard"
echo ""

# Вставляем команду в терминал, но не выполняем (через read -e)
read -e -p "➡️  " -i "openclaw onboard"

echo ""
echo "💡 Теперь нажмите ENTER для выполнения команды выше."
