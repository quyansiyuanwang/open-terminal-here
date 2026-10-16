# Project context - open-terminal-here

- GitHub: https://github.com/quyansiyuanwang/open-terminal-here
- A macOS Finder Quick Action (Automator workflow) that opens kitty at the
  current Finder folder. When a remote-control-enabled kitty instance exists,
  the folder is opened as a new tab in that window instead of a new window.
- **Owner username: `quyansiyuanwang`.** Use it in every URL, badge, and
  example. Never write `<owner>` or any other placeholder.
- Install with `./install.sh`; the workflow is copied to `~/Library/Services/`
  and registered with `pbs -update`.
- The terminal integration requires `allow_remote_control socket-only` and
  `listen_on unix:${HOME}/.cache/kitty-remote` in `~/.config/kitty/kitty.conf`;
  see `kitty.conf.snippet`.
- Documentation is bilingual: `README.md` (English) and `README.zh-CN.md`
  (Chinese). Keep the two in sync when changing behavior.
- Shell scripts are POSIX `sh`; validate with
  `shellcheck install.sh uninstall.sh`.
- Commit messages: concise and conventional. Do not create git tags unless the
  user explicitly asks.
