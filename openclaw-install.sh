#!/bin/bash
# ============================================
# Скрипт установки Node.js 22 и OpenClaw
# ============================================

set -e  # Останавливать скрипт при ошибке

# Цвета для вывода
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

log_info()    { echo -e "${GREEN}[INFO]${NC} $1"; }
log_warn()    { echo -e "${YELLOW}[WARN]${NC} $1"; }
log_error()   { echo -e "${RED}[ERROR]${NC} $1"; }

# Проверка прав суперпользователя
if [[ $EUID -ne 0 ]]; then
   log_error "Этот скрипт должен выполняться от имени root"
   exit 1
fi

log_info "Начало установки..."

# ============================================
# 1. Установка Node.js 22
# ============================================
log_info "Установка Node.js 22..."
curl -fsSL https://deb.nodesource.com/setup_22.x | bash - || {
    log_error "Не удалось добавить репозиторий NodeSource"
    exit 1
}

apt update && apt install -y nodejs || {
    log_error "Не удалось установить Node.js"
    exit 1
}

log_info "Node.js $(node -v) и npm $(npm -v) установлены"

# ============================================
# 2. Настройка глобальной npm директории
# ============================================
log_info "Настройка глобальной npm директории..."

NPM_GLOBAL_DIR="/root/.npm-global"
mkdir -p "$NPM_GLOBAL_DIR"

npm config set prefix "$NPM_GLOBAL_DIR"

# Добавляем PATH в ~/.bashrc, если ещё не добавлен
if ! grep -q "npm-global/bin" ~/.bashrc; then
    echo 'export PATH=/root/.npm-global/bin:$PATH' >> ~/.bashrc
    log_info "PATH добавлен в ~/.bashrc"
else
    log_warn "PATH уже настроен в ~/.bashrc"
fi

# Применяем изменения для текущей сессии
export PATH="$NPM_GLOBAL_DIR/bin:$PATH"

log_info "npm глобальная директория настроена"

# ============================================
# 3. Установка OpenClaw
# ============================================
log_info "Установка OpenClaw..."

npm install -g openclaw@latest || {
    log_error "Не удалось установить OpenClaw"
    exit 1
}

# Проверка версии
log_info "Проверка версии OpenClaw..."
openclaw --version || {
    log_warn "Не удалось получить версию OpenClaw (возможно, требуется перезагрузка терминала)"
}

# ============================================
# 4. Инициализация OpenClaw
# ============================================
log_info "Инициализация OpenClaw..."
log_warn "Запуск 'openclaw onboard' требует взаимодействия пользователя"

# Запускаем интерактивную инициализацию
openclaw onboard

# ============================================
# Завершение
# ============================================
log_info "✅ Установка завершена!"
echo ""
echo "Рекомендации:"
echo "  • Для применения переменных окружения в новых сессиях: source ~/.bashrc"
echo "  • Проверить установку: openclaw --version"
echo "  • Документация: https://github.com/openclaw/openclaw"
