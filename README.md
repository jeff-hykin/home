Tools for setting up new machines (Debian-based Linux and macOS).

### Setup
```shell
. <(curl -fsSL https://raw.githubusercontent.com/jeff-hykin/home/master/Commands/setup || wget -qO- https://raw.githubusercontent.com/jeff-hykin/home/master/Commands/setup)
```

Interactive installer that handles SSH keys, git, brew, nix, deno, zsh, starship, CLI tools, GUI apps, VS Code extensions, and more.

### Grab Commands
```shell
function iex { alias irm='curl -fsSL $url_|sh;:';t=${1#?};eval export ${t%|*};};iex '$url_="https://raw.githubusercontent.com/jeff-hykin/home/refs/heads/master/Commands/grab_commands.ps1";irm $url_|iex'
```

Interactive picker to install individual commands from this repo into `~/.local/bin`. Ensures `~/.local/bin` is on your PATH.
