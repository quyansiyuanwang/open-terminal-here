# Open Terminal Here

[![CI](https://github.com/quyansiyuanwang/open-terminal-here/actions/workflows/ci.yml/badge.svg)](https://github.com/quyansiyuanwang/open-terminal-here/actions/workflows/ci.yml)

English | [简体中文](README.zh-CN.md)

A Finder Quick Action for macOS that opens [kitty](https://sw.kovidgoyal.net/kitty/)
at the current Finder folder. When a kitty instance with remote control is already
running, the folder is opened as a new **tab** in that window instead of as a
separate window.

## Features

- Triggered from Finder by a keyboard shortcut (assigned in System Settings) or
  from the Finder Services / Quick Actions menu.
- Works with an empty selection: it reads the current directory of the front
  Finder window.
- Reuses an existing kitty window as a new tab through kitty remote control, so
  repeated use does not accumulate windows or Dock icons.
- Falls back to launching a new kitty window when no remote-control-enabled
  instance exists.
- Configurable terminal application, launch type (tab, split, OS window), and
  target window.

## Requirements

- macOS 13 or later (developed and tested on macOS 15).
- kitty installed at `/Applications/kitty.app`.
- No Xcode project is required; the service is a plain Automator workflow.

## How it works

```
Finder --(Service / shortcut)--> OpenTerminalHere.workflow
                                    |  Run Shell Script
                                    +-- resolve directory:
                                    |     1. argument passed by Finder
                                    |     2. front Finder window (AppleScript)
                                    |     3. $HOME
                                    +-- find kitty remote socket
                                    |     ~/.cache/kitty-remote-<pid>
                                    +-- if found: kitty @ launch --type=tab --cwd=<dir>
                                    +-- else:     open -na kitty --args --directory=<dir>
```

The service has no input requirement and is scoped to Finder
(`NSRequiredContext` = `com.apple.finder`), so the shortcut is only active while
Finder is the frontmost application.

## Installation

### 1. Install the workflow

```sh
./install.sh
```

This copies `OpenTerminalHere.workflow` to `~/Library/Services/` and refreshes the
services database.

### 2. Enable kitty remote control

Append the following to `~/.config/kitty/kitty.conf`:

```conf
allow_remote_control socket-only
listen_on unix:${HOME}/.cache/kitty-remote
```

`listen_on` is applied at startup. Open a new kitty window, or restart kitty, for
the socket to appear.

### 3. Bind a keyboard shortcut

System Settings -> Keyboard -> Keyboard Shortcuts... -> Services -> enable
`在当前位置打开终端` (Open Terminal Here) -> click the shortcut field and press a
key combination.

A shortcut declared inside the workflow is not honored by Finder, so this step is
required.

## Usage

- In Finder, press the shortcut. Nothing needs to be selected.
- Alternatively, right-click a blank area and choose Services / Quick Actions ->
  `在当前位置打开终端`.

The first invocation creates a kitty window and its remote-control socket;
subsequent invocations add tabs to that window.

## Configuration

### Use a different terminal application

Edit the final lines of `Contents/Resources/document.wflow`, replace the kitty
commands, then run `/System/Library/CoreServices/pbs -update`.

### Open a split or an OS window instead of a tab

In the script, change `--type=tab` to one of:

- `--type=window` for a split in the current tab,
- `--type=os-window` for a separate OS window.

### Change which kitty window receives the tab

The script selects the socket with the smallest PID, which is the oldest window.
To prefer the newest window, change the loop so it keeps the largest PID instead.

## Troubleshooting

- **The shortcut does nothing.** Confirm the service is enabled under System
  Settings -> Keyboard Shortcuts -> Services. Reopen the settings application or
  run `killall Finder`.
- **A new window opens every time instead of a tab.** No remote-control socket was
  found. Verify that `allow_remote_control` and `listen_on` are present and that at
  least one kitty window was started after they were added.
- **The first run asks for permission to control Finder.** Allow it. The permission
  is required to read the front Finder window's directory.
- **Several Dock icons for kitty.** Each kitty OS window is a separate process.
  Tabs opened through this service do not create new processes; windows opened
  manually remain separate.

## Uninstall

```sh
rm -rf ~/Library/Services/OpenTerminalHere.workflow
/System/Library/CoreServices/pbs -update
```

Remove the two lines from `~/.config/kitty/kitty.conf` if remote control is no
longer needed.

## Layout

```
open-terminal-here/
+-- .github/workflows/ci.yml
+-- OpenTerminalHere.workflow/
|   +-- Contents/
|       +-- Info.plist
|       +-- Resources/document.wflow
+-- AGENTS.md
+-- CHANGELOG.md
+-- LICENSE
+-- Makefile
+-- README.md                     # this file (English)
+-- README.zh-CN.md               # Chinese
+-- install.sh
+-- kitty.conf.snippet
+-- uninstall.sh
```

## Security note

`allow_remote_control socket-only` lets any process that can reach the socket
control kitty. The socket is placed under `~/.cache`, inside the user's home
directory, which is not readable by other users on the machine.
