export NIXPKGS_ALLOW_UNFREE=1

if [ -e "/home/$(whoami)/.nix-profile/etc/profile.d/nix.sh" ]
then
    . "/home/$(whoami)/.nix-profile/etc/profile.d/nix.sh"

elif [ -f "/etc/profile.d/nix.sh" ]
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
    if [ -d "$HOME/.nix-defexpr/channels" ]
    then
        export NIX_PATH="$NIX_PATH:$HOME/.nix-defexpr/channels"
    fi
    
    if [ -d "/nix/var/nix/profiles/per-user/$(whoami)/channels" ]
    then
        export NIX_PATH="$NIX_PATH:/nix/var/nix/profiles/per-user/$(whoami)/channels"
    fi
fi

# 
# setup nix certificate
# 
if [ "$(uname)" = "Darwin" ] 
then
    export NIX_SSL_CERT_FILE="/etc/ssl/certs/ca-certificates.crt"
    # check if file exists
    if ! [ -f "$NIX_SSL_CERT_FILE" ]
    then
        echo 
        echo 
        echo 'creating certificate file (for https and git) since its not created yet and NIX needs one'
        echo 
        sudo security 'export' -t certs -f pemseq -k /System/Library/Keychains/SystemRootCertificates.keychain -o "$NIX_SSL_CERT_FILE"
    fi
else
    export NIX_SSL_CERT_FILE="/etc/ssl/certs/ca-certificates.crt" # NixOS, Ubuntu, Debian, Gentoo, Arch
    if ! [ -f "$NIX_SSL_CERT_FILE" ]
    then
        export NIX_SSL_CERT_FILE="/etc/ssl/ca-bundle.pem" # openSUSE Tumbleweed
        if ! [ -f "$NIX_SSL_CERT_FILE" ]
        then
            export NIX_SSL_CERT_FILE="/etc/ssl/certs/ca-bundle.crt" # Old NixOS
            if ! [ -f "$NIX_SSL_CERT_FILE" ]
            then
                export NIX_SSL_CERT_FILE="/etc/pki/tls/certs/ca-bundle.crt" # Fedora, CentOS
                if ! [ -f "$NIX_SSL_CERT_FILE" ]
                then
                    export NIX_SSL_CERT_FILE=""
                fi
            fi
        fi
    fi
fi