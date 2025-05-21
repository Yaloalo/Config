
#!/usr/bin/env bash
# Create the one symlink Zsh needs in your home
ln -sf "$HOME/.config/zsh/.zsh/.zshenv" "$HOME/.zshenv"
echo "Linked ~/.zshenv → ~/.config/zsh/.zsh/.zshenv"
