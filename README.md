# MacOSX Shell Scripts

Collection of sh for convenience.

## How to use

The scripts are portable and can be run from any place in you system.

However, it is recommended to check out this repository in `~/bin` directory. Most system have already defined the path for this directory. Otherwise, the path can be added manually in `~/.zprofile` or `~/.zshrc`.

```
if [ -d "$HOME/bin" ]; then
    export PATH="$HOME/bin:$PATH"
fi
```

### Install with multiple major releases

Scripts that list `--default` in their usage can keep several major versions installed. Pass `--default` to make a major version the default, so later updates of that major version carry over. Pass `--default` with another major version to switch:

```
nodejs-install 24 --default
```

## License

MacOSX Shell Scripts is licensed under MIT license. See LICENSE file and NOTICE file for more details.
