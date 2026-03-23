#!/bin/bash
# Installer for Smart Gemini CLI Wrapper
# https://github.com/oravepo546-stack/Gemini-CLI-api-key-rotation

INSTALL_DIR="$HOME/.gemini"
SCRIPT_NAME="wrapper.sh"
FULL_PATH="$INSTALL_DIR/$SCRIPT_NAME"

echo "[*] Initializing Smart Gemini CLI Rotation setup..."

# 1. Create structure
mkdir -p "$INSTALL_DIR"

# 2. Copy core logic
if [ -f "$SCRIPT_NAME" ]; then
    cp "$SCRIPT_NAME" "$FULL_PATH"
    chmod +x "$FULL_PATH"
    echo "[+] Wrapper script installed to $FULL_PATH"
else
    echo "[-] Error: wrapper.sh not found in current directory."
    exit 1
fi

# 3. Handle shell integration (alias)
BASHRC="$HOME/.bashrc"
ALIAS_CMD="alias gemini='$FULL_PATH'"

if ! grep -q "alias gemini=" "$BASHRC"; then
    echo -e "\n# Gemini CLI Key Rotation Alias\n$ALIAS_CMD" >> "$BASHRC"
    echo "[+] 'gemini' alias added to $BASHRC"
else
    # Update existing alias if found
    sed -i "s|alias gemini=.*|$ALIAS_CMD|g" "$BASHRC"
    echo "[*] Updated existing 'gemini' alias in $BASHRC"
fi

# 4. Final instructions
echo "------------------------------------------------------------"
echo "[SUCCESS] Installation complete."
echo "[ACTION] 1. Put your API keys in: $INSTALL_DIR/api_keys.txt"
echo "[ACTION] 2. Run: source ~/.bashrc"
echo "------------------------------------------------------------"
