<img align="left" width="64" height="64" src="data/icons/64.svg">
<h1 class="rich-diff-level-zero">Icon Browser</h1>

[![Translation status](https://l10n.elementary.io/widgets/icon-browser/-/svg-badge.svg)](https://l10n.elementary.io/engage/icon-browser/)

![Screenshot](data/screenshot.png?raw=true)

## Building, Testing, and Installation

Run `flatpak-builder` to configure the build environment, download dependencies, build, and install

```bash
    flatpak-builder build io.elementary.iconbrowser.yml --user --install --force-clean --install-deps-from=appcenter
```

Then execute with

```bash
    flatpak run io.elementary.iconbrowser
```
