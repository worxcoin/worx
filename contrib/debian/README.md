
Debian
====================
This directory contains files used to package worxd/worx-qt
for Debian-based Linux systems. If you compile worxd/worx-qt yourself, there are some useful files here.

## worx: URI support ##


worx-qt.desktop  (Gnome / Open Desktop)
To install:

	sudo desktop-file-install worx-qt.desktop
	sudo update-desktop-database

If you build yourself, you will either need to modify the paths in
the .desktop file or copy or symlink your worxqt binary to `/usr/bin`
and the `../../share/pixmaps/worx128.png` to `/usr/share/pixmaps`

worx-qt.protocol (KDE)

