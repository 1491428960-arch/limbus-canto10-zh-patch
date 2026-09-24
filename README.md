# 边狱巴士中文补丁 · Limbus Company Chinese Translation Patch

<div align="center">

## 如果这个补丁帮到了你，欢迎请我喝杯咖啡 ☕
## If this patch helped you, please consider buying me a coffee ☕

<img src="assets/donate-alipay.jpg" alt="支付宝打赏付款码 / Alipay donation QR code" width="420">

**自愿打赏，不影响补丁下载和使用。**<br>
**Donations are completely optional and do not affect access to the patch.**

</div>

---

## ⚠️ 请注意：本仓库此前的 Part 1 补丁已过时

**如果你现在装的是本仓库早先发布的版本（第十章 Part 1，100 个文件），请改用零协（Zero Association）官方发布的 Part 1 中文补丁。**

零协的官方版本在译名统一性、文本覆盖度和后续维护上都优于我们早先的自制版本 —— 既然官方的已经出来了，就没有理由让旧版继续留在你的游戏里。

**当前 `patch/` 目录只包含第十章 Part 2 的新增内容（100 个文件）**，与零协的 Part 1 补丁**互不冲突，可以同时安装**：

| 补丁 | 负责范围 |
|---|---|
| 零协官方补丁 | Part 1，以及其他所有它已覆盖的章节 |
| 本补丁 | 只补充零协尚未覆盖的 Part 2 新增资源（`-a1c10p2` 等） |

**安装顺序：建议先装零协的补丁，再装本补丁。** 两个补丁的文件名不重叠，但按这个顺序装可以避免任何意外覆盖。

---

## ⚠️ Notice: the previous Part 1 patch in this repo is outdated

**If you have the earlier release from this repository (Canto 10 Part 1, 100 files), please switch to the official Part 1 Chinese patch published by Zero Association (零协).**

Their official release is better than our earlier self-made version in terminology consistency, text coverage, and ongoing maintenance. Now that the official version exists, there is no reason to keep the old one in your game.

**The `patch/` folder now contains only the new Canto 10 Part 2 content (100 files)**, which does not conflict with Zero Association's Part 1 patch and can be installed alongside it:

| Patch | Scope |
|---|---|
| Zero Association official patch | Part 1 and every other chapter it already covers |
| This patch | Only the Part 2 resources Zero Association does not cover yet (such as `-a1c10p2`) |

**Install order: install the Zero Association patch first, then this one.** The two patches share no filenames, but this order avoids any accidental overwrite.

---

## 中文说明

### 这是什么

这是《边狱巴士》（Limbus Company）第十章 **Part 2** 新增主线资源的中文语言补丁，面向使用 `LLC_zh-CN` 语言目录的 Windows 版本。

当前发布内容包括：

- 100 个 JSON 语言资源文件（第十章 Part 2 新增资源）；
- RPG 模式中新格式对话、角色头衔、左上角说话人姓名和立绘说话高亮所需的资源；
- RPG 模式中插入的传统 `StoryData` 对话；
- 与已有 `LLC_zh-CN` 文本保持一致的角色名、专有名词和前作相关译名。

### 翻译范围与约束

- 原文依据韩语资源翻译；
- 不使用英文资源作为翻译底稿；
- 不使用 RO 的脑叶公司 / 图书馆佬翻译作为来源；
- 内部 ID 保持原值，避免破坏 RPG 模式中的说话人匹配、姓名显示和立绘高亮；
- 已尽量沿用已有中文语言资源的显示译名，统一同一词条在不同模式中的写法。

本项目是在零协（Zero Association）此前公开的《边狱巴士》中文化工作、译名积累和相关资源整理基础上继续进行的社区补充项目。我们在本次主线资源中延续了这些已有成果，并向零协的维护者和参与者致以诚挚感谢。感谢你们此前的翻译、术语整理与分享，为后续汉化工作提供了重要基础。

本仓库是独立的社区延续项目，不代表零协官方发布、授权或背书，也不表示双方存在隶属或合作关系。

这不是 Project Moon 官方中文补丁，也不包含游戏本体、音频或其他受版权保护的完整游戏资源。

### 一键安装（推荐）

#### 第一步：关闭游戏

安装前请完全退出《边狱巴士》。如果 Steam 或游戏进程仍在运行，先退出后再安装。

#### 第二步：下载并解压

点击 GitHub 页面上的 **Code → Download ZIP**，把压缩包完整解压到任意位置。不要只把 `patch` 文件夹单独拖出来，因为安装器需要和它处于同一仓库目录。

#### 第三步：双击安装

双击仓库根目录中的：

```text
install.bat
```

按照提示输入《边狱巴士》的游戏根目录。例如：

```text
C:\Program Files (x86)\Steam\steamapps\common\Limbus Company
```

注意：这里要选择包含以下内容的目录，而不是 `LimbusCompany_Data` 或 `Lang` 子目录：

```text
Limbus Company\
├─ LimbusCompany.exe
└─ LimbusCompany_Data\
```

安装器会自动检查目录、验证所有 JSON，然后把补丁复制到：

```text
LimbusCompany_Data\Lang\LLC_zh-CN
```

安装前如果目标目录中已经存在同名文件，安装器会自动备份，不会覆盖后无记录可查。

### 命令行安装（可选）

如果你更习惯终端，可以在仓库根目录运行：

```powershell
powershell.exe -NoProfile -ExecutionPolicy Bypass -File .\install.ps1 `
  -GamePath "C:\Program Files (x86)\Steam\steamapps\common\Limbus Company"
```

只检查、不复制文件：

```powershell
powershell.exe -NoProfile -ExecutionPolicy Bypass -File .\install.ps1 `
  -GamePath "C:\Program Files (x86)\Steam\steamapps\common\Limbus Company" -DryRun
```

### 自动备份与恢复

安装器会把将要覆盖的旧文件备份到游戏根目录下的时间戳文件夹，例如：

```text
Limbus Company\_limbus_canto10_zh_backup_20260918-120000-123\
```

如果想恢复安装前的文件：

1. 关闭游戏；
2. 打开上述备份文件夹；
3. 将备份文件复制回 `LimbusCompany_Data\Lang\LLC_zh-CN`，允许覆盖；
4. 重新启动游戏。

安装器只会备份和复制本补丁实际涉及的同名 JSON，不会清理其他语言文件，也不会修改注册表或系统设置。

### 游戏更新后怎么办

Steam 或游戏更新可能替换语言资源。遇到更新后中文消失、部分文本恢复韩文或资源结构变化时，重新下载最新补丁并再次运行 `install.bat` 即可。每次安装都会重新检查 JSON，并为这次覆盖创建新的备份目录。

### 常见问题

#### 提示“不是《边狱巴士》的游戏根目录”

你输入的路径层级不对。请填写同时包含 `LimbusCompany.exe` 和 `LimbusCompany_Data` 的目录，不要填写 `LimbusCompany_Data`、`Lang` 或 `LLC_zh-CN` 子目录。

#### 双击后窗口一闪而过

请从压缩包完整解压后运行，确保 `install.bat`、`install.ps1` 和 `patch` 文件夹在同一层。也可以在 PowerShell 中手动运行上面的命令行安装方式，以查看详细错误。

#### 安装器提示游戏正在运行

完全退出游戏以及相关残留进程后再运行。安装器只会阻止正在运行的目标游戏进程，不会结束进程，也不会强制修改正在使用的文件。

#### 仍有个别地方没有中文

本补丁只覆盖仓库中列出的当前资源范围。游戏更新后如果新增资源，或者某段文字来自未纳入本批次的资源文件，请在 GitHub Issues 中附上截图、资源名称和游戏版本。

### 反馈与贡献

欢迎通过 GitHub Issues 报告：

- 未翻译文本；
- 角色姓名、头衔或专有名词不统一；
- RPG 模式中说话人姓名、立绘高亮或文本显示异常；
- 安装器识别路径、备份或复制失败。

反馈时请尽量提供游戏版本、资源文件名和截图；不要上传账号信息、Cookie、Token 或完整游戏目录。

---

## 贡献方与鸣谢 / Credits & Acknowledgements

- **前置汉化与术语基础 / Previous localization foundation：** 零协（Zero Association）此前公开的《边狱巴士》中文化工作、译名积累与相关整理。
- **本次资源整理与安装器 / Current resource processing and installer：** 本仓库维护者 / Maintainers of this repository。

我们向零协的维护者和参与者致以诚挚感谢。你们此前的翻译、术语整理、资源整理与分享，为本项目继续处理新主线资源提供了重要基础。

We sincerely thank the maintainers and contributors of Zero Association (零协) for their previous translation, terminology work, resource organization, and generous sharing. Their work provided an important foundation for this community continuation project.

本仓库是独立的社区延续项目，不代表零协官方发布、授权或背书，也不表示双方存在隶属或合作关系。

This repository is an independent community continuation project. It is not an official release of, authorized by, endorsed by, or affiliated with Zero Association.

---

## English Instructions

### What this is

This is a Chinese language patch for the **Canto 10 Part 2** main-story resources of **Limbus Company**, intended for the Windows version that uses the `LLC_zh-CN` language folder.

The current release contains:

- 100 JSON language resource files (new Canto 10 Part 2 resources);
- RPG-mode resources for new-format dialogue, character titles, speaker names in the upper-left corner, and speaking-character portrait highlighting;
- Traditional `StoryData` dialogue inserted into the RPG mode;
- Consistent character names, terminology, and references to earlier Project Moon titles based on the existing `LLC_zh-CN` translations.

For Part 1, please use the official Chinese patch published by Zero Association (零协). The earlier Part 1 release from this repository is outdated.

This community patch continues from the earlier Chinese localization work, accumulated terminology, and related resource organization publicly shared by Zero Association (零协). We sincerely thank the maintainers and contributors of Zero Association for the foundation they provided through their translation, terminology work, and sharing.

This repository is an independent community continuation project and does not represent an official release, authorization, endorsement, or affiliation of Zero Association.

### Translation policy

- The Korean resources are used as the source text;
- English resources are not used as the translation source;
- RO / Library of Ruina fan translations are not used as the translation source;
- Internal IDs are preserved so RPG speaker matching, name display, and portrait highlighting keep working;
- Existing Chinese display translations are reused where available, and repeated labels are normalized across modes.

This is not an official Project Moon Chinese patch. It contains no game executable, audio, or complete copyrighted game assets.

### One-click installation (recommended)

#### 1. Close the game

Exit Limbus Company completely before installing. If Steam or the game process is still running, close it first.

#### 2. Download and extract

On the GitHub page, choose **Code → Download ZIP** and extract the entire archive anywhere. Do not move only the `patch` folder; the installer expects it next to the scripts.

#### 3. Run the installer

Double-click:

```text
install.bat
```

Enter the Limbus Company game root when prompted, for example:

```text
C:\Program Files (x86)\Steam\steamapps\common\Limbus Company
```

The selected folder must contain both:

```text
Limbus Company\
├─ LimbusCompany.exe
└─ LimbusCompany_Data\
```

Do not enter the `LimbusCompany_Data`, `Lang`, or `LLC_zh-CN` subfolder. The installer validates the patch JSON files and copies them to:

```text
LimbusCompany_Data\Lang\LLC_zh-CN
```

Existing files with the same names are backed up automatically before they are replaced.

### Command-line installation (optional)

From the repository root:

```powershell
powershell.exe -NoProfile -ExecutionPolicy Bypass -File .\install.ps1 `
  -GamePath "C:\Program Files (x86)\Steam\steamapps\common\Limbus Company"
```

Validate without copying anything:

```powershell
powershell.exe -NoProfile -ExecutionPolicy Bypass -File .\install.ps1 `
  -GamePath "C:\Program Files (x86)\Steam\steamapps\common\Limbus Company" -DryRun
```

### Backup and restore

The installer stores overwritten files in a timestamped folder beside the game directory, for example:

```text
Limbus Company\_limbus_canto10_zh_backup_20260918-120000-123\
```

To restore the previous files, close the game, copy the files from that backup folder back to `LimbusCompany_Data\Lang\LLC_zh-CN`, and allow overwriting.

Only files that this patch actually replaces are backed up. The installer does not delete unrelated language files, change the registry, or change system settings.

### After a game update

Steam or a game update may replace language resources. If Chinese text disappears, some text returns to Korean, or the resource structure changes, download the latest patch and run `install.bat` again. Every run validates the JSON files and creates a fresh backup for overwritten files.

### Troubleshooting

- **Wrong game folder:** choose the folder containing both `LimbusCompany.exe` and `LimbusCompany_Data`.
- **The window closes immediately:** extract the complete ZIP and keep `install.bat`, `install.ps1`, and `patch` at the same level. Alternatively, run the PowerShell command above to see the full error.
- **The game is running:** close the game and any remaining target game process. The installer does not terminate processes or force-edit locked files.
- **Some text is still not translated:** report the screenshot, resource filename, and game version in GitHub Issues. New game updates may add resources outside the current release.

### Feedback and contributions

GitHub Issues are welcome for untranslated text, inconsistent names or titles, RPG speaker/portrait display problems, and installer path or backup errors. Please include the game version, resource filename, and a screenshot when possible. Do not upload account information, cookies, tokens, or your complete game directory.

---

## Disclaimer

This is a fan-made translation patch. Limbus Company and related intellectual property belong to their respective rights holders. Use it at your own discretion and keep a backup before modifying game files.
