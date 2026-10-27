{ config, pkgs, ... }:


let
  autostart = ''
    #!${pkgs.bash}/bin/bash

    firefox -no-remote -CreateProfile "vm /home/user/.mozilla/firefox/vm"
    cat <<EOF > "/home/user/.mozilla/firefox/vm/user.js"
    user_pref("font.size.variable.x-western", 14);
    user_pref("layout.css.devPixelsPerPx", "0.9");
    EOF
    firefox \
      --kiosk \
      --profile /home/user/.mozilla/firefox/vm/ \
      --remote-debugging-port 9222 \
      127.0.0.1 2>/tmp/firefox-debug.log &
  '';

  firefox-control = pkgs.writeScriptBin "firefox-control" (builtins.readFile ../firefox-control.sh);

in
{
  networking.firewall.allowedTCPPorts = [ 9222 ];

  # Openbox runs /etc/xdg/openbox/autostart at startup.
  environment.etc."xdg/openbox/autostart".source = pkgs.writeScript "autostart" autostart;

  i18n.defaultLocale = "en_US.UTF-8";
  console.font = "ter-132n";
  console.keyMap = "us";
  console.packages = with pkgs; [ terminus_font ];

  # Enable X11 without a display manager
  services.xserver = {
    enable = true;
    windowManager.openbox.enable = true;
    displayManager.lightdm.enable = true;

    xkb.layout = "us";
    videoDrivers = [ "qxl" ]; # Otherwise we can't use the 2560x1440.
    dpi = 256;

    monitorSection = ''
      Modeline "2880x1920_60.00" 473.06 2880 3104 3424 3968 1920 1921 1924 1987 -HSync +Vsync
      Option "PreferredMode" "2880x1920_60.00"
    '';
  };

  services.displayManager.defaultSession = "none+openbox";
  services.displayManager.autoLogin = {
    enable = true;
    user = "user";
  };

  services.libinput.enable = true;

  # TODO The two Xcursor lines don't seem to work, but maybe I need to restart the session.
  # TODO Same for this line:
  # Which is called fonts.optimizeForVeryHighDPI is later version of NixOS.
  services.xserver.displayManager.sessionCommands = ''
    xrdb "${pkgs.writeText "xrdb.conf" ''
      XTerm*faceName:             xft:DejaVu Sans Mono for Powerline:size=8
      XTerm*utf8:                 2

      Xft.dpi: 256
      Xft.autohint: 0
      Xft.lcdfilter: lcddefault
      Xft.hintstyle: hintfull
      Xft.hinting: 1
      Xft.antialias: 1
      Xft.rgba: rgb

      Xcursor.theme: Vanilla-DMZ
      ! Apparently size only works if a theme exists?
      Xcursor.size: 48
    ''}"
  '';

  systemd.services."display-manager".after = [
    "network-online.target"
    "systemd-resolved.service"
  ];
  # Without this, the ordering above doesn't make systemd wait for the network.
  systemd.services."display-manager".wants = [ "network-online.target" ];

  system.stateVersion = "24.05";

  # Set up user environment
  users.users.user = {
    isNormalUser = true;
    # extraGroups = [ "wheel" ]; # For sudo access
    password = "password";
  };

  # Add Firefox and control scripts to system packages
  environment.systemPackages = with pkgs; [
    curl
    firefox
    firefox-control
    xdotool
  ];

  # Allow user to run system commands without a password
  # security.sudo.wheelNeedsPassword = false;

  # Specify how to run QEMU
  virtualisation.memorySize = 2048;
  virtualisation.resolution = {
    x = 2880;
    y = 1920;
  };
  virtualisation.qemu.options = [
    "-vga virtio"
    "-device VGA,vgamem_mb=64"
    "-full-screen" # Use Ctrl-Alt-F to exit fullscreen.
  ];
  virtualisation.forwardPorts = [
    { from = "host"; host.port = 9222; guest.port = 9222; }
  ];
}
