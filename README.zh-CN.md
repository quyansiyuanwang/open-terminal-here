# 在当前位置打开终端

[![CI](https://github.com/quyansiyuanwang/open-terminal-here/actions/workflows/ci.yml/badge.svg)](https://github.com/quyansiyuanwang/open-terminal-here/actions/workflows/ci.yml) [![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](LICENSE) [![Platform: macOS](https://img.shields.io/badge/Platform-macOS-blue.svg)](#环境要求)

[English](README.md) | 简体中文

一个 macOS Finder 快速操作：用 [kitty](https://sw.kovidgoyal.net/kitty/) 在
Finder 当前文件夹打开终端。若已有开启远程控制的 kitty 实例，则在**该窗口内新建
tab**，而不是再开一个独立窗口。

## 功能

- 可在 Finder 中用快捷键触发（快捷键在系统设置里绑定），也可从 Finder 的
  服务 / 快速操作菜单触发。
- 无需选中任何东西：直接读取最前 Finder 窗口的当前目录。
- 通过 kitty 远程控制，把新终端作为 tab 加入已有窗口，反复使用不会堆积窗口和
  Dock 图标。
- 若没有开启远程控制的实例，则回退为打开一个新的 kitty 窗口。
- 终端程序、打开方式（tab / 分屏 / 独立窗口）、目标窗口均可配置。

## 环境要求

- macOS 13 或更高（在 macOS 15 上开发与测试）。
- kitty 安装于 `/Applications/kitty.app`。
- 不需要 Xcode 工程；该服务就是一个普通的 Automator workflow。

## 工作原理

```
Finder --(服务 / 快捷键)--> OpenTerminalHere.workflow
                                |  Run Shell Script
                                +-- 解析目录:
                                |     1. Finder 传入的参数
                                |     2. 最前 Finder 窗口(AppleScript)
                                |     3. $HOME
                                +-- 查找 kitty 远程控制 socket
                                |     ~/.cache/kitty-remote-<pid>
                                +-- 找到: kitty @ launch --type=tab --cwd=<dir>
                                +-- 否则: open -na kitty --args --directory=<dir>
```

该服务不要求输入，并限定在 Finder 中生效（`NSRequiredContext` =
`com.apple.finder`），因此快捷键只在 Finder 位于最前时可用。

## 安装

### 1. 安装 workflow

```sh
./install.sh
```

脚本会把 `OpenTerminalHere.workflow` 复制到 `~/Library/Services/`，并刷新服务
数据库。

### 2. 开启 kitty 远程控制

在 `~/.config/kitty/kitty.conf` 末尾追加：

```conf
allow_remote_control socket-only
listen_on unix:${HOME}/.cache/kitty-remote
```

`listen_on` 只在启动时生效。需要新开一个 kitty 窗口，或重启 kitty，socket 才会
出现。

### 3. 绑定快捷键

系统设置 -> 键盘 -> 键盘快捷键… -> 服务 -> 勾选「在当前位置打开终端」-> 点它
右侧的快捷键区域，按下想要组合键。

写在 workflow 里的快捷键 Finder 不认，因此这一步是必需的。

## 使用

- 在 Finder 中按快捷键即可，无需选中任何东西。
- 也可右键空白处 -> 服务 / 快速操作 -> 「在当前位置打开终端」。

第一次调用会创建一个 kitty 窗口及其远程控制 socket；之后的调用都会把新终端作为
tab 加进该窗口。

## 配置

### 换用其它终端程序

编辑 `Contents/Resources/document.wflow` 末尾的命令，替换 kitty 相关调用，然后
执行 `/System/Library/CoreServices/pbs -update`。

### 改成开分屏或独立窗口

在脚本中把 `--type=tab` 改成：

- `--type=window`：在当前标签页内分屏；
- `--type=os-window`：独立的 OS 窗口。

### 改变接收 tab 的 kitty 窗口

脚本选择 PID 最小的 socket，也就是最旧的窗口。若想优先用最新的窗口，把选择循环
改为保留最大的 PID 即可。

## 常见问题

- **快捷键没反应。** 确认服务已在 系统设置 -> 键盘快捷键 -> 服务 中启用。重开
  系统设置，或执行 `killall Finder`。
- **每次都开新窗口而不是 tab。** 没有找到远程控制 socket。确认已加入
  `allow_remote_control` 与 `listen_on`，并且至少有一个 kitty 窗口是在加入之后
  启动的。
- **首次运行提示控制「访达」权限。** 允许即可；读取最前 Finder 窗口目录需要该
  权限。
- **Dock 出现多个 kitty 图标。** 每个 kitty OS 窗口是独立进程。通过本服务打开的
  tab 不会新建进程；手动打开的窗口仍各自独立。

## 卸载

```sh
rm -rf ~/Library/Services/OpenTerminalHere.workflow
/System/Library/CoreServices/pbs -update
```

若不再需要远程控制，可从 `~/.config/kitty/kitty.conf` 删掉那两行。

## 目录结构

```
open-terminal-here/
+-- .github/
|   +-- workflows/ci.yml
|   +-- ISSUE_TEMPLATE/bug_report.md
|   +-- pull_request_template.md
|   +-- release.yml
+-- OpenTerminalHere.workflow/
|   +-- Contents/
|       +-- Info.plist
|       +-- Resources/document.wflow
+-- AGENTS.md
+-- CHANGELOG.md
+-- LICENSE
+-- Makefile
+-- README.md                     # 英文说明
+-- README.zh-CN.md               # 本文件（中文）
+-- install.sh
+-- kitty.conf.snippet
+-- uninstall.sh
```

## 安全说明

`allow_remote_control socket-only` 允许任何能访问该 socket 的进程控制 kitty。
socket 放在用户主目录下的 `~/.cache`，主目录对其它用户不可读，因此本机其它用户
无法访问。
