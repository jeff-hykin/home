{
	description = "My awesome flake";

	inputs = {
		nixpkgs.url = "github:nixos/nixpkgs/nixos-22.05";
        thing.url = "github:jeff-hykin/snowball/909217601e390f95f0773072c2fd8fd730ace838";

		# Snowfall Lib is not required, but will make configuration easier for you.
		snowfall-lib = {
			url = "github:snowfallorg/lib";
			inputs.nixpkgs.follows = "nixpkgs";
		};

		cowsay = {
			url = "github:snowfallorg/cowsay";
			inputs.nixpkgs.follows = "nixpkgs";
		};
	};

	outputs = inputs: {
        packages.aarch64-darwin.default = builtins.trace (inputs.thing.outputs == {}) inputs.nixpkgs.legacyPackages.aarch64-darwin.cowsay;
    };
}