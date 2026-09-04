#!/bin/bash
# Brygge installer
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
BIN_TARGET="$HOME/bin/brygge"
DEFAULT_VAULT="$HOME/Documents/Obsidian Vault"
DEFAULT_PREF="Claude Memory/brygge-preferences.md"

echo "🍺 Installing brygge..."

# 1. Check deps
for cmd in fswatch claude; do
    if ! command -v "$cmd" >/dev/null; then
        echo "❌ Missing dependency: $cmd"
        case "$cmd" in
            fswatch) echo "   Install: brew install fswatch" ;;
            claude)  echo "   Install: https://docs.anthropic.com/claude-code" ;;
        esac
        exit 1
    fi
done

# 2. Symlink into ~/bin
mkdir -p "$HOME/bin"
ln -sf "$SCRIPT_DIR/bin/brygge" "$BIN_TARGET"
chmod +x "$SCRIPT_DIR/bin/brygge"
echo "✅ Linked $BIN_TARGET → $SCRIPT_DIR/bin/brygge"

# 3. Ensure ~/bin is in PATH
SHELL_RC=""
if [ -n "${ZSH_VERSION:-}" ] || [[ "$SHELL" == */zsh ]]; then
    SHELL_RC="$HOME/.zshrc"
elif [ -n "${BASH_VERSION:-}" ] || [[ "$SHELL" == */bash ]]; then
    SHELL_RC="$HOME/.bashrc"
fi

if [ -n "$SHELL_RC" ]; then
    if ! grep -q 'HOME/bin' "$SHELL_RC" 2>/dev/null; then
        echo 'export PATH="$HOME/bin:$PATH"' >> "$SHELL_RC"
        echo "✅ Added ~/bin to PATH in $SHELL_RC"
    fi

    if ! grep -q "# brygge autostart" "$SHELL_RC" 2>/dev/null; then
        cat >> "$SHELL_RC" << 'EOF'

# brygge autostart (singleton — safe to call from multiple shells)
[ -x ~/bin/brygge ] && nohup ~/bin/brygge > /dev/null 2>&1 & disown
EOF
        echo "✅ Added autostart to $SHELL_RC"
    fi
fi

# 4. Copy preferences to vault if it doesn't exist
VAULT="${BRYGGE_VAULT:-$DEFAULT_VAULT}"
if [ -d "$VAULT" ]; then
    PREF_TARGET="$VAULT/$DEFAULT_PREF"
    if [ ! -f "$PREF_TARGET" ]; then
        mkdir -p "$(dirname "$PREF_TARGET")"
        cp "$SCRIPT_DIR/examples/preferences.md" "$PREF_TARGET"
        echo "✅ Copied preferences template to $PREF_TARGET"
    else
        echo "ℹ️  Preferences file already exists at $PREF_TARGET (leaving it alone)"
    fi
else
    echo "⚠️  Vault not found at $VAULT — set BRYGGE_VAULT and re-run, or create ~/.config/brygge/config"
fi

echo ""
echo "🎉 Done! Start brygge now with:  brygge &"
echo "   Or restart your shell and it will start automatically."
echo ""
echo "Trigger a response by writing @claude on its own line in any .md note and saving."
