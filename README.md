Tools for setting up new machines (Debian-based Linux and macOS).

### Setup
```shell
. <(curl -fsSL https://raw.githubusercontent.com/jeff-hykin/home/master/Commands/setup || wget -qO- https://raw.githubusercontent.com/jeff-hykin/home/master/Commands/setup)
```

Interactive installer that handles SSH keys, git, brew, nix, deno, zsh, starship, CLI tools, GUI apps, VS Code extensions, and more.

### Grab Commands
```shell
. <(curl -fsSL https://raw.githubusercontent.com/jeff-hykin/home/master/Commands/grab_commands || wget -qO- https://raw.githubusercontent.com/jeff-hykin/home/master/Commands/grab_commands)
```

Interactive picker to install individual commands from this repo into `~/.local/bin`. Ensures `~/.local/bin` is on your PATH.
