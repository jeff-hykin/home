A bunch of tools I use for setting up new machines. Mostly Debian-based and MacOS


### Installing Nix, all the basic tools, and setting up home
```shell
. <(curl -fsSL https://raw.githubusercontent.com/jeff-hykin/home/master/Commands/setup_main || wget -qO- https://raw.githubusercontent.com/jeff-hykin/home/master/Commands/setup_main)
```

### Installing Nix
```shell
. <(curl -fsSL https://raw.githubusercontent.com/jeff-hykin/home/master/Commands/setup_nix || wget -qO- https://raw.githubusercontent.com/jeff-hykin/home/master/Commands/setup_nix)
```

### Installing Basics
```shell
. <(curl -fsSL https://raw.githubusercontent.com/jeff-hykin/home/master/Commands/setup_basic_cli_stuff || wget -qO- https://raw.githubusercontent.com/jeff-hykin/home/master/Commands/setup_basic_cli_stuff)
```

### Setting up SSH (server)
```shell
. <(curl -fsSL https://raw.githubusercontent.com/jeff-hykin/home/master/Commands/setup_ssh_server || wget -qO- https://raw.githubusercontent.com/jeff-hykin/home/master/Commands/setup_ssh_server)
```

### Setting up SSH keys (needs Deno, which is installed with basics)
```shell
. <(curl -fsSL https://raw.githubusercontent.com/jeff-hykin/home/master/Commands/setup_ssh_keys || wget -qO- https://raw.githubusercontent.com/jeff-hykin/home/master/Commands/setup_ssh_keys)
```

### Setting up ZeroTier
```shell
. <(curl -fsSL https://raw.githubusercontent.com/jeff-hykin/home/master/Commands/setup_zerotier || wget -qO- https://raw.githubusercontent.com/jeff-hykin/home/master/Commands/setup_zerotier)
```