# for tamu build server
rm -f ./nix-user-chroot-bin-1.2.2-x86_64-unknown-linux-musl
wget https://github.com/nix-community/nix-user-chroot/releases/download/1.2.2/nix-user-chroot-bin-1.2.2-x86_64-unknown-linux-musl
mkdir -p "$HOME/Commands/"
mv ./nix-user-chroot-bin-1.2.2-x86_64-unknown-linux-musl "$HOME/Commands/nix-user-chroot"
export PATH="$PATH:$HOME/Commands"

mkdir -m 0755 ~/.nix
nix-user-chroot ~/.nix bash -c 'curl -L https://releases.nixos.org/nix/nix-2.3.7/install | sh'