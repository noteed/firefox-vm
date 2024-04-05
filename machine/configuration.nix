{ config, pkgs, ... }:

{
  # Enable X11 without a display manager, running Firefox directly
  services.xserver = {
    enable = true;
    displayManager.defaultSession = "custom";
    displayManager.session = [
      {
        manage = "desktop";
        name = "custom";
        start = ''
          exec firefox --kiosk https://refli.be
        '';
      }
    ];
    displayManager.autoLogin = {
      enable = true;
      user = "user";
    };
  };

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
}
