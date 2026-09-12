#!/usr/bin/env bash
# common.sh — общие хелперы для всех yandex-* скиллов
# Подключается через: source "$(dirname "$0")/common.sh"

set -euo pipefail

# Ищем .env рядом со скиллом (config/.env), поднимаясь от scripts/
SKILL_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
ENV_FILE="$SKILL_DIR/config/.env"

if [ -f "$ENV_FILE" ]; then
  set -a
  source "$ENV_FILE"
  set +a
else
  echo "[ERROR] Не найден $ENV_FILE. Скопируйте config/.env.example в config/.env и заполните токены." >&2
  exit 1
fi

require_var() {
  local name="$1"
  if [ -z "${!name:-}" ]; then
    echo "[ERROR] Переменная $name не задана в config/.env" >&2
    exit 1
  fi
}

require_bin() {
  local bin="$1"
  if ! command -v "$bin" >/dev/null 2>&1; then
    echo "[ERROR] Требуется утилита '$bin'. Установите её (brew install $bin / apt install $bin)." >&2
    exit 1
  fi
}

require_bin curl
require_bin jq

# Единая точка логирования (в stderr, чтобы не засорять JSON-вывод в stdout)
log() { echo "[$(date +%H:%M:%S)] $*" >&2; }
