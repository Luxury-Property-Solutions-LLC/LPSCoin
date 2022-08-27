
Debian
====================
This directory contains files used to package lpscoinsd/lpscoins-qt
for Debian-based Linux systems. If you compile lpscoinsd/lpscoins-qt yourself, there are some useful files here.

## lpscoins: URI support ##


lpscoins-qt.desktop  (Gnome / Open Desktop)
To install:

	sudo desktop-file-install lpscoins-qt.desktop
	sudo update-desktop-database

If you build yourself, you will either need to modify the paths in
the .desktop file or copy or symlink your lpscoinsqt binary to `/usr/bin`
and the `../../share/pixmaps/lpscoins128.png` to `/usr/share/pixmaps`

lpscoins-qt.protocol (KDE)

