<img align="left" width="64" height="64" src="data/icons/64.svg">
<h1 class="rich-diff-level-zero">Icon Browser</h1>

[![Translation status](https://l10n.elementary.io/widgets/icon-browser/-/svg-badge.svg)](https://l10n.elementary.io/engage/icon-browser/)

![LookBook Screenshot](data/screenshot.png?raw=true)

## Building, Testing, and Installation


You'll need the following dependencies to build:
* libgranite-7-dev
* libgtk-4-dev
* libgtksourceview-5-dev
* meson
* valac

Run `meson build` to configure the build environment and then change to the build directory and run `ninja` to build

    meson build --prefix=/usr 
    cd build
    ninja

To install, use `ninja install`, then execute with `io.elementary.iconbrowser`

    ninja install
    io.elementary.iconbrowser
