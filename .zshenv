if [ -e "$HOME"/.nix-profile/etc/profile.d/nix.sh ]; then . "$HOME"/.nix-profile/etc/profile.d/nix.sh; fi # added by Nix installer

# Ensure ~/.local/bin is on PATH early (starship lives here and is needed before rc files run)                                                                                                                                                                                                                                                                                                                                                  
case ":$PATH:" in
    *":$HOME/.local/bin:"*) ;;
    *) export PATH="$HOME/.local/bin:$PATH" ;;
esac