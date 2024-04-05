{ config, pkgs, ... }:


let
  autostart = ''
    #!${pkgs.bash}/bin/bash
    # End all lines with '&' to not halt startup script execution

    firefox --kiosk https://refli.be/ &
  '';

in
{
  # Overlay to set custom autostart script for openbox
  # From the answer at
  # https://discourse.nixos.org/t/how-to-configure-nixos-for-kiosk-or-fullscreen-applications/21855/2
  nixpkgs.overlays = with pkgs; [
    (_self: super: {
      openbox = super.openbox.overrideAttrs (_oldAttrs: rec {
        postFixup = ''
          ln -sf /etc/openbox/autostart $out/etc/xdg/openbox/autostart
        '';
      });
    })
  ];

  # By defining the script source outside of the overlay, we don't have to
  # rebuild the package every time we change the startup script.
  environment.etc."openbox/autostart".source = pkgs.writeScript "autostart" autostart;

  # Enable X11 without a display manager
  services.xserver = {
    enable = true;
    windowManager.openbox.enable = true;
    displayManager.lightdm.enable = true;
    displayManager.defaultSession = "none+openbox";
    displayManager.autoLogin = {
      enable = true;
      user = "user";
    };

    layout = "us";
    libinput.enable = true;
    videoDrivers = [ "qxl" ]; # Otherwise we can't use the 2560x1440.
  };

  systemd.services."display-manager".after = [
    "network-online.target"
    "systemd-resolved.service"
  ];

  # Set up user environment
  users.users.user = {
    isNormalUser = true;
    # extraGroups = [ "wheel" ]; # For sudo access
    password = "password";
  };

  # Add Firefox to system packages
  environment.systemPackages = with pkgs; [ firefox ];

  # Allow user to run system commands without a password
  # security.sudo.wheelNeedsPassword = false;

  # Specify how to run QEMU
  virtualisation.resolution = {
    x = 2560;
    y = 1440;
  };
  virtualisation.qemu.options = [
    "-vga virtio"
    "-display gtk"
    "-device VGA,vgamem_mb=64"
    "-full-screen" # Use Ctrl-Alt-F to exit fullscreen.
  ];
}
