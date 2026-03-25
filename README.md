Tools for setting up new machines (Debian-based Linux and macOS).

### Setup
```shell
function iex { alias irm='curl -fsSL $url_|sh;:';t=${1#?};eval export ${t%|*};};iex '$url_="https://raw.githubusercontent.com/jeff-hykin/home/refs/heads/master/Commands/setup.ps1";irm $url_|iex'
```

Interactive installer that handles SSH keys, git, brew, nix, deno, zsh, starship, CLI tools, GUI apps, VS Code extensions, and more.

### Grab Commands
```shell
mkdir -p "$HOME/.local/bin";
curl -fsSL https://raw.githubusercontent.com/jeff-hykin/home/master/Commands/grab_commands.ps1 >"$HOME/.local/bin/grab_commands"
chmod +x "$HOME/.local/bin/grab_commands"
"$HOME/.local/bin/grab_commands"
```
<!-- function iex { alias irm='curl -fsSL $url_|sh;:';t=${1#?};eval export ${t%|*};};iex '$url_="https://raw.githubusercontent.com/jeff-hykin/home/refs/heads/master/Commands/grab_commands.ps1";irm $url_|iex' -->

Interactive picker to install individual commands from this repo into `~/.local/bin`. Ensures `~/.local/bin` is on your PATH.
