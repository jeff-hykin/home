{
    description = "Testing out flakeshub ";
    inputs = {
        nixpkgs.url = "https://flakehub.com/f/NixOS/nixpkgs/0.1.514192.tar.gz";

        # flake-compat.url = "https://flakehub.com/f/edolstra/flake-compat/1.0.1.tar.gz";

        # fenix = {
        #     url = "https://flakehub.com/f/nix-community/fenix/0.1.1565.tar.gz";
        #     inputs.nixpkgs.follows = "nixpkgs";
        # };

        # naersk = {
        #     url = "github:nix-community/naersk";
        #     inputs.nixpkgs.follows = "nixpkgs";
        # };
    };

    outputs = { self, ... }@inputs:
        let
            a = 10;
            # inherit (inputs.nixpkgs) lib;

            # lastModifiedDate = self.lastModifiedDate or self.lastModified or "19700101";

            # version = "${builtins.substring 0 8 lastModifiedDate}-${self.shortRev or "dirty"}";

            # forSystems = s: f: lib.genAttrs s (system: f rec {
            #     inherit system;
            #     pkgs = import inputs.nixpkgs { inherit system; overlays = [ self.overlays.default ]; };
            # });

            # forAllSystems = forSystems [ "x86_64-linux" "aarch64-linux" "x86_64-darwin" "aarch64-darwin" ];

            # fenixToolchain = system: with inputs.fenix.packages.${system};
            #     combine ([
            #         stable.clippy
            #         stable.rustc
            #         stable.cargo
            #         stable.rustfmt
            #         stable.rust-src
            #     ] ++ inputs.nixpkgs.lib.optionals (system == "x86_64-linux") [
            #         targets.x86_64-unknown-linux-musl.stable.rust-std
            #     ] ++ inputs.nixpkgs.lib.optionals (system == "aarch64-linux") [
            #         targets.aarch64-unknown-linux-musl.stable.rust-std
            #     ]);

        in
            {
                # overlays.default = final: prev: rec {
                #     somthing = somthing;
                # };
                
                # packages = forAllSystems ({ system, pkgs, ... }: rec {
                #     fh = pkgs.fh;
                #     default = pkgs.fh;
                # });

                #   devShells = forAllSystems ({ system, pkgs, ... }:
                #       {
                #           default = pkgs.mkShell {
                #               name = "dev";

                #               LIBCLANG_PATH = "${pkgs.libclang.lib}/lib";
                #               NIX_CFLAGS_COMPILE = lib.optionalString pkgs.stdenv.isDarwin "-I${pkgs.libcxx.dev}/include/c++/v1";

                #               nativeBuildInputs = with pkgs; [ pkg-config clang ];
                #               buildInputs = with pkgs; [
                #                   (fenixToolchain stdenv.hostPlatform.system)
                #                   cargo-watch
                #                   rust-analyzer
                #                   nixpkgs-fmt
                #                   gcc.cc.lib
                #               ]
                #               ++ lib.optionals (pkgs.stdenv.isDarwin) (with pkgs; with darwin.apple_sdk.frameworks; [
                #                   libiconv
                #                   Security
                #                   SystemConfiguration
                #               ]);
                #           };
                #       });
          };
}
