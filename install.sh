#!/usr/bin/env bash
set -e

REPO_URL="https://github.com/murat-yasar/zsh-t3-shortcuts"
TARGET="$HOME/.zsh-t3-shortcuts"
ZSHRC="$HOME/.zshrc"
SOURCE_LINE="source $TARGET/zsh-t3-shortcuts.plugin.zsh"

echo "Installing zsh-t3-shortcuts..."

if [ -d "$TARGET" ]; then
  echo "Directory already exists: $TARGET"
else
  git clone "$REPO_URL" "$TARGET"
fi

if ! grep -Fxq "$SOURCE_LINE" "$ZSHRC"; then
  echo "" >> "$ZSHRC"
  echo "$SOURCE_LINE" >> "$ZSHRC"
  echo "Added to .zshrc"
else
  echo "Already sourced in .zshrc"
fi

echo "✅ Installed successfully. Restart your shell or run:"
echo "source ~/.zshrc"
