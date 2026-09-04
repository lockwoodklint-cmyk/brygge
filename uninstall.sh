#!/bin/bash
# Brygge uninstaller
set -u

echo "🍺 Uninstalling brygge..."

# Stop running instance
if pgrep -f "bin/brygge" >/dev/null; then
    pkill -f "bin/brygge" 2>/dev/null || true
    pkill -f "fswatch.*Obsidian" 2>/dev/null || true
    echo "✅ Stopped running brygge"
fi

# Remove symlink
rm -f "$HOME/bin/brygge"
echo "✅ Removed ~/bin/brygge"

# Remove autostart from shell rc files
for RC in "$HOME/.zshrc" "$HOME/.bashrc"; do
    if [ -f "$RC" ] && grep -q "# brygge autostart" "$RC"; then
        # Remove the two-line autostart block
        sed -i '' '/# brygge autostart/,/^$/d' "$RC" 2>/dev/null \
            || sed -i '/# brygge autostart/,/^$/d' "$RC"
        echo "✅ Removed autostart from $RC"
    fi
done

# Remove state dir
STATE_DIR="${XDG_STATE_HOME:-$HOME/.local/state}/brygge"
[ -d "$STATE_DIR" ] && rm -rf "$STATE_DIR" && echo "✅ Removed state dir $STATE_DIR"

echo ""
echo "🎉 Done. Your preferences file in the vault was NOT touched."
echo "   Remove it manually if desired: Claude Memory/brygge-preferences.md"
