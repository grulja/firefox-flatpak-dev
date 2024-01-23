# Firefox for Flatpak development
Scripts to build and run Firefox as a Flatpak app from your local Firefox build.
It's a combination of the runme.sh script from the official Firefox build script
with some bits from https://github.com/xhorak/FirefoxFlatpakDevel.

### Build
Path to the build directory is usually your ~/dev/firefox/dist or similar path.
```
./build.sh [PATH_TO_FIREFOX_BUILD_DIRECTORY]
```

### Run
Command to run inside the Firefox flatpak container. Defaults to `firefox`.
```
./run.sh [CMD]
```

