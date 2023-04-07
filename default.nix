{
    pkgs ? (builtins.import 
        (builtins.fetchTarball
            ({url="https://github.com/NixOS/nixpkgs/archive/ce6aa13369b667ac2542593170993504932eb836.tar.gz";})
        )
        ({})
    ),
    deno ? pkgs.deno,
    bash ? pkgs.bash,
    sd ? pkgs.sd,
}:
    pkgs.stdenv.mkDerivation {
        pname = "jeff-tools";
        version = "0.1.0";
        
        dontPatchShebangs = 1;
        # builder = "${bash}/bin/bash"; # <- should work but doesnt: /nix/store/lkw407y1x1v5bg6hc290c5ry1qaabbgl-bash-5.1-p16/bin/bash: cannot execute binary file
        gcc = pkgs.gcc;
        coreutils = pkgs.coreutils;
        src = builtins.fetchTarball ({
            url="https://github.com/jeff-hykin/home/archive/0d1c13b3ff96ebde79369ce88ee138a994bd9bca.tar.gz";
        });
        
        buildInputs = [
            deno
            bash
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
    