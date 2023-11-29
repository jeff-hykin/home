{
	description = "My awesome flake";

	inputs = {
		nixpkgs.url = "github:nixos/nixpkgs/nixos-22.05";

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

	outputs = inputs:
		inputs.snowfall-lib.mkFlake {
			inherit inputs;
			src = ./.;

			overlays = with inputs; [
				# To make this flake's packages available in your NixPkgs package set.
				cowsay.overlay
			];

			outputs-builder = channels:
				let
					inherit (channels.nixpkgs) system;
					# Use packages directly from the input instead.
					inherit (inputs.cowsay.packages.${system}) cowsay cow2img;
				in {
					# Use the packages in some way.
				};
		};
}