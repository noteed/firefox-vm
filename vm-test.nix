let
  sources = import ./nix/sources.nix;
  nixpkgs = import sources.nixpkgs {};

  config = { ... }: {
    imports = [
      ./machine/configuration.nix
      "${toString sources.nixpkgs}/nixos/modules/virtualisation/qemu-vm.nix"
    ];
  };

in nixpkgs.nixosTest {
  name = "firefox-vm/text";
  enableOCR = true;
  nodes = {
    machine1 = config;
  };

  # This can't work because the machine doesn't have network access,
  # unless we disable the sandbox.
  testScript = ''
    start_all();
    machine1.wait_for_unit("display-manager");
    machine1.wait_for_x();
    machine1.wait_for_text("Refli");
    machine1.screenshot("screenshot");
  '';
  }
