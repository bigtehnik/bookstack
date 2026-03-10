#!/bin/bash

# Проверка на запуск от root
if [ "$EUID" -ne 0 ]; then
  echo "Пожалуйста, запустите скрипт от имени root (sudo)."
  exit 1
fi

echo "=== Шаг 1: Установка Node.js 22 ==="
curl -fsSL https://deb.nodesource.com/setup_22.x | bash -
apt install -y nodejs

echo -e "\n=== Шаг 2: Настройка глобальной npm директории ==="
mkdir -p /root/.npm-global
npm config set prefix '/root/.npm-global'

# Добавляем путь в .bashrc, если его еще нет
if ! grep -q "export PATH=/root/.npm-global/bin:\$PATH" ~/.bashrc; then
    echo 'export PATH=/root/.npm-global/bin:$PATH' >> ~/.bashrc
fi

# Применяем изменения для текущей сессии скрипта
export PATH=/root/.npm-global/bin:$PATH
source ~/.bashrc

echo -e "\n=== Шаг 3: Установка OpenClaw и проверка версии ==="
npm install -g openclaw@latest
openclaw --version

echo -e "\n=== Готово ==="
read -p "для старта нажмите ENTER" -r

# Вставка команды в терминал для пользователя
# -e включает readline (редактирование)
# -i задает начальный текст
echo -e "\nКоманда вставлена. Нажмите Enter для запуска или отредактируйте:"
read -e -p "> " -i "openclaw onboard" user_command

# Запуск того, что ввел пользователь
eval "$user_command"
