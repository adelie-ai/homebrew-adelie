# Adelie Homebrew tap

A Homebrew tap that builds the Adelie desktop assistant, its clients, and its MCP
servers **from source**. Each component is its own formula with its **own**
dependency set, so you only pull in what a given piece needs — no GTK unless you
install the GTK client, no espeak-ng unless you install voice, and so on.

## Tapping

This repo is the tap. Add it (the name **must** be `adelie-ai/adelie` so the
meta-formulas resolve their cross-references):

```sh
# from a local checkout (substitute your path)
brew tap adelie-ai/adelie /path/to/homebrew-adelie

# …or, once it's pushed to github.com/adelie-ai/homebrew-adelie
brew tap adelie-ai/adelie
```

Then install components by their plain name (Homebrew resolves them within the tap):

```sh
brew install adelie-daemon          # the assistant orchestrator (Linux)
brew install adele-tui              # terminal client (Linux + macOS)
brew install weather-forecast-mcp   # one MCP server
```

## Components

| Formula | Binary(ies) | Platform | Extra deps (beyond rust + cmake) |
|---|---|---|---|
| `adelie-daemon` | `desktop-assistant-daemon`, `adelie-dbus-bridge` | Linux | `postgresql@17`, `pgvector`, pkg-config |
| `adele-tui` | `adele` | Linux + macOS | — |
| `adele-gtk` | `adele-gtk` | Linux | `gtk4`, `webkitgtk`, pkg-config |
| `adele-voice` | `adele-voice` | Linux | `espeak-ng`, `alsa-lib`, pkg-config |
| `cve-mcp` | `cve-mcp` | Linux + macOS | — |
| `fileio-mcp` | `fileio-mcp` | Linux + macOS | — |
| `gen-mcp` | `genmcp` | Linux + macOS | — |
| `geocode-mcp` | `geocode-mcp` | Linux + macOS | — |
| `internet-radio-mcp` | `internet-radio-mcp` | Linux + macOS | `mpv` |
| `tasks-mcp` | `tasks-mcp` | Linux + macOS¹ | — |
| `terminal-mcp` | `terminal-mcp` | Linux + macOS | — |
| `timeclock-mcp` | `timeclock-mcp` | Linux + macOS | — |
| `weather-forecast-mcp` | `weather-forecast-mcp` | Linux + macOS | — |
| `adelie` | *(meta)* | Linux | installs `adelie-daemon` + `adele-tui` |
| `adelie-mcp` | *(meta)* | Linux + macOS | installs all 9 MCP servers |

¹ `tasks-mcp` builds on macOS but its `dbus` activation mode needs a D-Bus session
bus (Linux); the stdio `serve` mode works anywhere.

`rust` and `cmake` are `:build` deps on every Rust formula (`cmake` covers the
`aws-lc-rs` rustls crypto provider, and whisper.cpp for voice).

## Wiring an MCP server into Claude / the assistant

Every MCP server runs over stdio with the `serve` subcommand:

```sh
claude mcp add weather -- weather-forecast-mcp serve
```

## Source pinning

Each formula has **two** sources:

- a **stable** `url` pinned to a specific `main` commit — `brew install <name>`
  builds that exact revision, reproducibly;
- a **`head`** spec — `brew install --HEAD <name>` builds the current `main`.

To move a formula to a newer commit, update the `revision:` (and, for
`adele-gtk`, the `DESKTOP_ASSISTANT_REV` constant + the `adelie-daemon` /
meta revisions to match).

> **Build needs network.** These formulas build from source and let `cargo`
> fetch crates during the build (normal `cargo build` behaviour), rather than
> vendoring every dependency as a Homebrew `resource`. That's fine for local
> `brew install`, but means they aren't set up for Homebrew CI bottling. To
> bottle them you'd vendor the crate graph.

## Caveats & platform notes

- **Platforms:** the daemon, GTK client, and voice service are Linux-only — they
  rely on the Secret Service keyring, D-Bus, systemd, GTK/WebKitGTK, and ALSA. The
  terminal client and the MCP servers build cleanly on both Linux and macOS.
- **`adelie-daemon` needs PostgreSQL + pgvector** at runtime (conversation store +
  embedding/FTS hybrid search). The formula installs `postgresql@17` + `pgvector`
  and the post-install caveats walk through `createdb` + `CREATE EXTENSION vector`.
- **`adele-gtk`** rewrites its `../desktop-assistant` path-deps to pinned git deps
  at build time (Homebrew builds each repo in isolation). If `brew install
  webkitgtk` isn't available on your distro, install the system WebKitGTK 6.0 dev
  package instead.
- **`adele-voice`** downloads STT/TTS model weights on first run (not bundled).
  After install: `adele-voice check-setup`. The wake word (`.rpw`) is recorded
  locally.
- **systemd:** `adelie-daemon` and `adele-voice` install their upstream user units
  under `<keg>/share/<name>/systemd` for reference; the caveats show how to copy
  them into `~/.config/systemd/user` with `ExecStart` pointed at the keg.

## Not in the tap

- **`adele-kde`** (Plasma KCM + plasmoids) — a KDE Plasma desktop component suite
  that must integrate with the *system* Qt6/KF6/Plasma, which Homebrew can't
  provide cleanly. Install it from its own repo with the project's `just` recipes
  (`just kcm-install`, `just widget-install`).
- **`pim-mcp`** (binary `calendar-mcp`), **`skills-mcp`**, **`web-mcp`** — no public
  git remote yet, so there's nothing for Homebrew to fetch. Push them to
  `github.com/adelie-ai/<repo>` and add a formula (copy `weather-forecast-mcp.rb`
  and swap the url/revision/binary; `pim-mcp` builds from `servers/calendar-mcp`).

## Licensing

This tap — the formula definitions in this repo — is BSD-2-Clause (see `LICENSE`),
matching the Homebrew convention for taps. That covers only the packaging
metadata; the Adelie software the formulas build is AGPL-3.0-or-later. MCP-server
formulas omit a `license` stanza pending confirmation of each repo's license.
