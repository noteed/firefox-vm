This is an attempt at running Firefox in a NixOS VM. I've tried Playwright, but
maybe a "real" Firefox will allow something more accurate (e.g. start Firefox
with a configuration for high-dpi display).

```
$ scripts/runvm.sh
```

Use Ctrl-Alt-F to exit the fullscreen mode, and use Ctrl-Alt-Q to quit QEMU
(this doesn't work while in fullscreen).
