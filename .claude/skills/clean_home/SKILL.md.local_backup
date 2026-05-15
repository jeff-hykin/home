---
name: clean_home
description: Clean up redundant lines auto-appended to rc files by installers
disable-model-invocation: true
allowed-tools: [Read, Edit, Bash, Grep, Glob]
---

# Clean Home

Installers (cargo, pixi, conda, nvm, etc.) frequently append lines to shell rc files. This repo has a startup file system (`~/bash_startup/` and `~/zsh_startup/`) that already handles PATH additions and env sourcing, so those appended lines are usually redundant.

## Steps

1. Run `git diff --name-only` and filter to these rc files: `.bashrc`, `.zshrc`, `.zshenv`, `.profile`, `.bash_profile`
2. For each changed file, run `git diff <file>` to see what was added
3. For each added line, search `~/bash_startup/` and `~/zsh_startup/` for equivalent functionality:
   - PATH additions (e.g. `export PATH=".../.cargo/bin:$PATH"`)
   - Env file sourcing (e.g. `. "$HOME/.cargo/env"`)
   - Tool initialization (e.g. `eval "$(tool init)"`)
4. If the added line is already handled by a startup file, remove it from the rc file
5. If the added line is NOT already handled, leave it in place but tell the user — suggest they create a proper startup file for it (with the naming convention `NN_NN_description.bash`)
6. Report a summary of what was cleaned and what was left
