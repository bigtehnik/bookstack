#!/bin/bash

# Выход при любой ошибке
set -e

# Цвета
BLUE="\033[1;34m"
GREEN="\033[1;32m"
YELLOW="\033[1;33m"
RED="\033[1;31m"
NC="\033[0m" # без цвета

# Функции для вывода
info() { echo -e "${BLUE}[INFO]${NC} $1"; }
success() { echo -e "${GREEN}[OK]${NC} $1"; }
warn() { echo -e "${YELLOW}[WARN]${NC} $1"; }
error() { echo -e "${RED}[ERROR]${NC} $1"; }

# Проверка root
if [ "$EUID" -ne 0 ]; then
  error "Пожалуйста, запустите этот скрипт от имени root (sudo)."
  exit 1
fi

info "### Шаг 1: Устанавливаем Node.js 22 ###"

apt-get update
apt-get install -y curl gnupg

curl -fsSL https://deb.nodesource.com/setup_22.x | bash -
apt-get install -y nodejs

success "Node.js установлен. Версия: $(node --version)"

info "### Шаг 2: Настройка глобальной npm директории ###"

mkdir -p /root/.npm-global
npm config set prefix '/root/.npm-global'

if ! grep -q "export PATH=/root/.npm-global/bin:\$PATH" ~/.bashrc; then
    echo 'export PATH=/root/.npm-global/bin:$PATH' >> ~/.bashrc
    success "Путь npm добавлен в ~/.bashrc"
else
    info "Путь npm уже присутствует в ~/.bashrc"
fi

export PATH=/root/.npm-global/bin:$PATH
success "PATH применён для текущей сессии"

info "### Шаг 3: Установка OpenClaw ###"

if [ -d "/root/.npm-global/lib/node_modules/openclaw" ]; then
    warn "Старая версия OpenClaw найдена, удаляем..."
    rm -rf /root/.npm-global/lib/node_modules/openclaw
fi

info "Очистка кеша npm..."
npm cache clean --force

info "Скачиваем и устанавливаем последнюю версию OpenClaw..."
npm install -g openclaw@2026.3.31

success "OpenClaw установлен успешно!"
success "Версия OpenClaw: $(openclaw --version)"

info "### Готово! ###"
echo -e "\nКоманда для запуска OpenClaw:"
echo -e "${BLUE}openclaw onboard${NC}"
read -p "Нажмите Enter, чтобы подтвердить и запустить..."  

openclaw onboard
success "Команда выполнена."
