{
    allowUnfree = true;
    # allowBroken = true;
    nixpkgs.config.permittedInsecurePackages = [
         "linux-4.13.16"
    ];
}