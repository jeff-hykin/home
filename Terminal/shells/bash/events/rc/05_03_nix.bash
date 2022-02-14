export NIXPKGS_ALLOW_UNFREE=1

# do the sourcing check if file exists
if [ -f "/etc/profile.d/nix.sh" ]
then
    . /etc/profile.d/nix.sh
else
    # 
    # manual fallback
    # 
    
    # per-user 
    __temp_var__user_nix_bin="/nix/var/nix/profiles/per-user/$(whoami)/profile/bin/"
    if [ -d "$__temp_var__user_nix_bin" ]
    then
        export PATH="$PATH:$__temp_var__user_nix_bin"
    fi
    unset __temp_var__user_nix_bin
    
    # default
    __temp_var__default_nix_bin="/nix/var/nix/profiles/default/bin/nix"
    if [ -d "$__temp_var__default_nix_bin" ]
    then
        export PATH="$PATH:$__temp_var__default_nix_bin"
    fi
    unset __temp_var__default_nix_bin
fi

# set nix path
if [ -z "$NIX_PATH" ]
then
    export NIX_PATH="${NIX_PATH:+$NIX_PATH:}$HOME/.nix-defexpr/channels:/nix/var/nix/profiles/per-user/$(whoami)/channels"
fi