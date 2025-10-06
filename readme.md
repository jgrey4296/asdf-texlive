<!-- readme.md -*- mode: gfm-mode -*- -->

An asdf plugin to install https://www.tug.org/texlive/

see: https://www.tug.org/texlive/doc/install-tl.html

Sets $XDG_CONFIG_HOME/texlive for the texmfconfig directory.
All other installation directories are within asdf.

Adds three commands:
- `asdf cmd texlive reqs` : create a `tex.reqs` file listing installed packages
- `asdf cmd texlive deps` : read a `tex.reqs` file and install the listed packages
- `asdf cmd texlive add`  : install a give package, and insert it into the `tex.reqs` file
