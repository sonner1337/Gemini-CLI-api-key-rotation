#!/bin/bash
# Install script for Smart Gemini CLI Wrapper

INSTALL_DIR="$HOME/.gemini"
SCRIPT_PATH="$INSTALL_DIR/wrapper.sh"

echo "[*] Настройка Gemini CLI Smart Rotation..."

mkdir -p "$INSTALL_DIR"
cp wrapper.sh "$SCRIPT_PATH"
chmod +x "$SCRIPT_PATH"

# Добавление алиаса в .bashrc
if ! grep -q "alias gemini=" "$HOME/.bashrc"; then
  echo "alias gemini='$SCRIPT_PATH'" >> "$HOME/.bashrc"
  echo "[+] Алиас 'gemini' добавлен в .bashrc"
else
  echo "[!] Алиас 'gemini' уже существует"
fi

echo "[*] Готово! Не забудь создать файл $INSTALL_DIR/api_keys.txt с твоими ключами."
echo "[*] Выполни: source ~/.bashrc"
