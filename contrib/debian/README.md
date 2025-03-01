# Debian Packaging for LPSCoin
This directory contains files for packaging `lpscoinsd` and `lpscoins-qt` (LPSCoin 4.1.0, March 2025) for Debian-based systems. Useful for self-compiled binaries too.

## Contents
- `examples/thered.conf`: Example config.
- `manpages/`: Manpages (`theredd.1`, `thered-qt.1`, `thered.conf.5`).
- `patches/`: Debian patches (`README`, `series`).
- `lpscoins-qt.desktop`: Gnome/Open Desktop URI support.
- `lpscoins-qt.protocol`: KDE URI support.

## Building Packages
1. Install deps: `sudo apt-get install build-essential devscripts debhelper`
2. Build: `dpkg-buildpackage -us -uc` (from source root; `.deb` files in parent dir).
Customize via `configure.ac` (e.g., `--with-daemon`, `--enable-wallet`).

## URI Support
### Gnome/Open Desktop
`sudo desktop-file-install contrib/debian/lpscoins-qt.desktop; sudo update-desktop-database`
Self-compiled: Symlink `lpscoins-qt` to `/usr/bin/`, copy `share/pixmaps/lpscoins128.png` to `/usr/share/pixmaps/`, or edit `.desktop` paths.

### KDE
`sudo cp contrib/debian/lpscoins-qt.protocol /usr/share/kde4/services/`
Ensure `lpscoins-qt` in `/usr/bin/` or adjust `.protocol` `Exec`.

## Notes
- Config: `~/.lpscoin/thered.conf` overrides defaults (see `examples/thered.conf`).
- Patches: Add to `patches/`, list in `patches/series` (see `patches/README`).
- RPC: Use `contrib/bitrpc/bitrpc.py` with `server=1`.

## Contributing
Submit Debian patches via issues/PRs here; upstream changes to https://github.com/Luxury-Property-Solutions-LLC/LPSCoin.
Maintained by the LPSCoin Debian team, March 2025.
