# check if file exists
if [[ -f "/etc/profile.d/nix.sh" ]]
then
    . /etc/profile.d/nix.sh
fi
export NIXPKGS_ALLOW_UNFREE=1