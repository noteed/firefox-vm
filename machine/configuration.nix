{ config, pkgs, ... }:

{
  # Enable the X server
  services.xserver.enable = true;
  services.xserver.displayManager.lightdm.enable = true;
  services.xserver.desktopManager.xfce.enable = true;

  # Set up the user environment
  users.users.user = {
    isNormalUser = true;
    extraGroups = [ "wheel" ]; # for sudo access
    password = "password";
  };

  # Install firefox
  environment.systemPackages = with pkgs; [ firefox ];

  # Autostart Firefox in fullscreen
  services.xserver.displayManager.sessionCommands = ''
    mkdir -p ~/.config/autostart
    cat > ~/.config/autostart/firefox.desktop <<EOF
    [Desktop Entry]
    Type=Application
    Exec=firefox --kiosk
    Hidden=false
    NoDisplay=false
    X-GNOME-Autostart-enabled=true
    Name[en_US]=Firefox
    Name=Firefox
    Comment[en_US]=Start Firefox in fullscreen mode
    Comment=Start Firefox in fullscreen mode
    EOF
  '';

  # Allow user to run system commands without a password
  security.sudo.wheelNeedsPassword = false;
}
