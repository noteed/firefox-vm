This is an attempt at running Firefox in a NixOS VM. I've tried Playwright, but
maybe a "real" Firefox will allow something more accurate (e.g. start Firefox
with a configuration for high-dpi display).

```
$ scripts/runvm.sh
```

Use Ctrl-Alt-F to exit the fullscreen mode, and use Ctrl-Alt-Q to quit QEMU
(this doesn't work while in fullscreen).

# Notes

The above `runvm.sh` script is already configured to do the "right things" but
here is how I achieved it manually first.

In the VM, to use 2880x1920:

```
$ gtf 2880 1920 60
$ xrandr --newmode "2880x1920_60.00" 473.06 2880 3104 3424 3969 1920 1921 1924 1987 -HSync +Vsync
$ xrandr --addmode Virtual-2 "2880x1920_60.00"
$ xrandr --output Virtual-2 --mode "2880x1920_60.00"
```

The corresponding NixOS bits are

```
  services.xserver = {
    monitorSection = ''
      Modeline "2880x1920_60.00" 473.06 2880 3104 3424 3968 1920 1921 1924 1987 -HSync +Vsync
      Option "PreferredMode" "2880x1920_60.00"
    '';
  };
```

In Firefox `about:config`: `layout.css.devPixelsPerPx` is set to 0.9. Then
restart Firefox.

The default font size is set to 14.

In the console, `window.devicePixelRatio` equals 2.4. (When
`layout.css.devPixelsPerPx` equals -1, it equals 2.60869).

This means that on a fullscreen 2880x1920 window, Firefox reports a viewport of
1200x800.
