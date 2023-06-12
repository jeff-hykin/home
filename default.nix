{
    # local install command: nix-env -i -f ./  
    pkgs ? (builtins.import 
        (builtins.fetchTarball
            ({url="https://github.com/NixOS/nixpkgs/archive/a161e8d1dfbd6a81630214e2a767a525cb92abfc.tar.gz";})
        )
        ({
            overlays = [ 
            ]; 
        })
    ),
    deno ? pkgs.deno,
    bash ? pkgs.bash,
    sd   ? pkgs.sd,
    doomEmacs ? (pkgs.callPackage 
        (
            builtins.fetchTarball 
            {
                url = https://github.com/nix-community/nix-doom-emacs/archive/master.tar.gz;
            }
        ) 
        {
            doomPrivateDir = ./.config/doom_emacs;
            dependencyOverrides = {
                "emacs-overlay" = (builtins.fetchTarball {
                    url = https://github.com/nix-community/emacs-overlay/archive/master.tar.gz;
                });
            };
            emacsPackagesOverlay = self: super: {
                gitignore-mode = pkgs.emacsPackages.git-modes;
                gitconfig-mode = pkgs.emacsPackages.git-modes;
                gitattributes-mode = pkgs.emacsPackages.git-modes;
            };
            # builtins.fetchTarball ({
            #     url="https://github.com/ballantony/doom-emacs-config/archive/master.tar.gz";
            # });
        }
    )
}:
    pkgs.stdenv.mkDerivation {
        pname = "jeff-tools";
        version = "0.1.0";
        
        dontPatchShebangs = 1;
        # builder = "${bash}/bin/bash"; # <- should work but doesnt: /nix/store/lkw407y1x1v5bg6hc290c5ry1qaabbgl-bash-5.1-p16/bin/bash: cannot execute binary file
        gcc = pkgs.gcc;
        coreutils = pkgs.coreutils;
        src = builtins.fetchTarball ({
            url="https://github.com/jeff-hykin/home/archive/a2e20f7ffeea8d0e2ec0c0ecab83bae9fbe437b7.tar.gz";
        });
        
        buildInputs = [
            deno
            bash
            doomEmacs
        ];
        
        # separateDebugInfo = true;
        # We override the install phase, as the emojify project doesn't use make
        installPhase = ''
            # 
            # imports
            # 
            sd="${sd}/bin/sd"        # TODO: it would be best to shell-escape these before interpolating
            deno="${deno}/bin/deno"  # TODO: it would be best to shell-escape these before interpolating
            bash="${bash}/bin/bash"  # TODO: it would be best to shell-escape these before interpolating
            
            
            mkdir -p "$out/bin"
            cp -r "$src/Commands/"* "$out/bin"
            cp -r '${doomEmacs}/bin/'* "$out/bin"
            
            # ensure executability
            chmod +x "$out/bin/"* &
            
            # patch bash shebangs 
            # TODO: keep in mind these replacement args need to be regex-escaped
            "$sd" '\A#!/usr/bin/env bash' '#!'"$bash" "$out/bin/"* &
            
            # patch deno shebangs
            # TODO: keep in mind these replacement args need to be regex-escaped
            "$sd" '\A#!/usr/bin/env -S deno' '#!/usr/bin/env -S '"$deno" "$out/bin/"* &
            
            wait $(jobs -p)
        '';
    }