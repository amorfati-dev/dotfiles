# Restore individual apps

Run the Homebrew and configuration-link steps in the main README first. These
notes cover the additional work needed when moving to a fresh Mac. The setup
script does not launch apps, change permissions, or enable background services.

## Neovim

`nvim/` preserves the active configuration: Rose Pine theme, keybindings,
Telescope search, Blink completion, Conform formatting, Gitsigns, Treesitter,
Mason, and language-server settings. Its 13 Lua files match the source setup;
`lazy-lock.json` records 12 plugin revisions. Old `after-old/` files and the
generated `keymap.html` are excluded.

The recorded Treesitter version requires **Neovim 0.12+** and **tree-sitter-cli
0.26.1+**. The source Mac had Neovim 0.12.5 and tree-sitter-cli 0.27.0. Install
Xcode Command Line Tools for the compiler, plus the Brewfile dependencies.
Node/npm supports language-server installation. Ripgrep and fd support search;
Ruff, StyLua, and Prettier support formatting. Prettier is explicitly listed
because the formatter configuration falls back to it when prettierd is absent.

1. Open `nvim` with internet available. Its bootstrap downloads lazy.nvim and the
   plugins. Wait for initial installation and builds.
2. Run `:Lazy restore` to restore the plugin revisions recorded in the lockfile.
   Wait for completion, quit, and reopen Neovim.
3. Mason installs the configured Lua language server, Pyright, and vtsls.
   Treesitter downloads/builds parsers asynchronously; allow it to finish and
   reopen a buffer if syntax highlighting is not ready yet.
4. Check `:checkhealth`, `:Mason`, and `:ConformInfo`, then try a file in a language
   you use. App downloads and a full fresh-Mac launch have not been tested here.

Use `:Lazy restore` when rebuilding the saved setup. `:Lazy update` deliberately
changes plugin versions; review and commit the resulting lockfile changes when
you want to keep them. The lockfile does not pin Homebrew packages, Mason server
versions, parser binaries, or the initial lazy.nvim bootstrap.

Neovim data and state stay in their normal locations outside this repository.
The repository stores the configuration and plugin list rather than installed
plugin copies, undo history, swap files, or sessions.

Reference: [lazy.nvim lockfiles](https://lazy.folke.io/usage/lockfile).

## AeroSpace and SketchyBar

These configurations work together: AeroSpace announces workspace changes and
SketchyBar displays the workspaces. Both programs and the JetBrainsMono Nerd Font
are in the Brewfile. AeroSpace's command PATH supports both Apple Silicon and
Intel Homebrew locations.

After applying the configuration, open AeroSpace and grant the permissions it
requests. The saved `start-at-login = false` is preserved. Start SketchyBar when
you want the custom menu bar; to run it as a login service, use:

```sh
brew services start felixkratz/formulae/sketchybar
```

The Wi-Fi script assumes interface `en0`. Check the Wi-Fi device on a replacement
Mac and adjust `sketchybar/plugins/wifi.sh` if needed. Network names are read at
runtime and are not stored in this repository. The included `front_app.sh` helper
is preserved, but the current menu bar does not enable a corresponding item.

## Karabiner-Elements

The configuration includes the selected profile, its four enabled rules, six
disabled saved rules, and both rule assets. Enabled rules cover a German-layout
symbol layer, Hyper app shortcuts, Caps Lock as Hyper/Escape, and arrow navigation.
The profile uses an ANSI keyboard type; review this if your replacement keyboard
has a different layout.

The app shortcuts reference **Cursor, Obsidian, Warp, Vivaldi, and Spotify**.
Install the apps you still use separately or edit those shortcuts. They were not
added to the Brewfile just because a saved shortcut refers to them.

Open Karabiner-Elements and complete its requested permissions/driver setup.
The installer links the entire `~/.config/karabiner` directory, which is required
for reliable detection of changes. If Karabiner was already running when the
directory was moved, restart its user service as documented by Karabiner:

```sh
launchctl kickstart -k "gui/$(id -u)/org.pqrs.service.agent.Karabiner-Console-User-Server"
```

GUI changes can rewrite the tracked JSON. Review those changes before committing.
Automatic backups stay ignored. Existing descriptions and imported rule metadata
are preserved; no new license or claim of original authorship has been added.

Reference: [Karabiner configuration location and directory links](https://karabiner-elements.pqrs.org/docs/manual/misc/configuration-file-path/).

## Atuin, tmux, and htop

Atuin's preferences preserve `enter_accept = true`, record sync, and its enabled
AI setting. This repository does not contain history, account sessions, encryption
keys, or databases. Restore or sign into your account separately if you use those
features. Pressing Enter on a selected history entry follows the saved behavior.

tmux uses **Ctrl+A** as its prefix, `|` and `-` for splits, and `h/j/k/l` or arrows
for pane navigation. Mouse support is enabled. Open a new tmux session to use it,
or deliberately reload the config in a running session.

htop stores layout and display preferences. The app can rewrite its file when
preferences change; if it replaces the file symlink, copy the intended changes
back to `htop/htoprc` and rerun the installer to recreate the link.
