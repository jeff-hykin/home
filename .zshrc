# All zsh startup logic lives in .zshenv now.
# To add shell config, create a file in ~/zsh_startup/
#
# Files are sourced alphabetically. Naming convention:
#   NN_NN_description.zsh       — always runs
#   NN_NN_description.bash      — shared with bash (symlinked)
#   NN_NN_description.if_login.zsh       — only in login shells
#   NN_NN_description.if_interactive.zsh — only in interactive shells
#
# Private/machine-specific config goes in ~/Personal/zsh_startup/
