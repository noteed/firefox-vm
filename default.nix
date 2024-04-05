let
  sources = import ./nix/sources.nix;
  nixpkgs = import sources.nixpkgs {};

  qemu = import "${toString sources.nixpkgs}/nixos/lib/eval-config.nix" {
    modules = [
      ./machine/configuration.nix
      "${toString sources.nixpkgs}/nixos/modules/virtualisation/qemu-vm.nix"
    ];
  };

in rec
  {
    runvm = qemu.config.system.build.vm;
  }
