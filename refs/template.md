chezmoi 的模板功能非常强大，它不仅支持 Go 语言标准的 `text/template` 语法，还完整集成了 **Sprig 扩展函数库**，并提供了一系列专为管理点文件（dotfiles）设计的**自定义函数**。

我们可以将这些函数分为几个核心类别，并探讨如何通过“组合”来解决复杂的配置需求。

---

### 1. 核心函数分类

#### 🛠️ 环境感知与系统交互（chezmoi 自定义）
这些函数是 chezmoi 的灵魂，用于根据设备、系统或路径动态调整配置。
*   **`joinPath`**: 跨平台拼接路径。
    *   `{{ joinPath .chezmoi.homeDir ".ssh" "id_rsa" }}`
*   **`lookPath`**: 检查某个可执行文件是否存在于 $PATH 中。
    *   `{{ if lookPath "zsh" }}chsh -s $(lookPath "zsh"){{ end }}`
*   **`output`**: 运行外部命令并获取其输出。
    *   `{{ output "date" "+%Y" | trim }}`（获取年份并去除换行符）

#### 🔐 密码与机密管理
chezmoi 提供了与主流密码管理器集成的专用函数：
*   **`onepassword` / `pass` / `bitwarden` / `keepassxc`**:
    *   `password: {{ onepasswordRead "item_name" "vault_name" }}`

#### 📝 数据处理与格式转换
处理 JSON、YAML、INI 或字符串：
*   **`fromJson` / `toYaml`**: 方便在模板中直接操作数据结构。
*   **`default`**: 提供默认值。
    *   `export EDITOR={{ .editor | default "vim" }}`
*   **`coalesce`**: 返回第一个非空的值（类似于 SQL 的 coalesce）。
    *   `{{ coalesce (env "VISUAL") (env "EDITOR") "nano" }}`

---

### 2. 函数组合的高级技巧

模板真正的威力在于**管道（Pipeline `|`）**和**括号嵌套**的组合使用。

#### 技巧 A：管道链式操作
就像 Linux shell 的管道一样，你可以将一个函数的输出作为下一个函数的输入。
```go
# 需求：获取主机名，转为大写，并在前方加前缀
{{ .chezmoi.hostname | upper | printf "MACHINE_%s" }}
```

#### 技巧 B：复杂逻辑判断
结合 `and` / `or` / `not` 进行多重条件过滤。
```go
# 需求：如果是 Linux 且安装了 git 才会执行
{{ if and (eq .chezmoi.os "linux") (lookPath "git") }}
  alias gl='git log --oneline --graph'
{{ end }}
```

#### 技巧 C：处理外部命令输出
通常 `output` 得到的字符串会带有换行符，必须配合 `trim` 使用。
```go
# 获取当前 Git 分支名作为配置的一部分
current_branch: {{ output "git" "branch" "--show-current" | trim }}
```

---

### 3. 实战案例：跨平台 Shell 配置

假设你有一套 `.zshrc`，在 Mac 和 Linux 上路径不同，且需要根据是否是工作机器来加载不同的环境变量：

```bash
# 使用 splitList 和 contains 组合判断
{{- $tags := splitList "," (env "MACHINE_TAGS" | default "personal") -}}

# 1. 自动根据系统设置路径
export PROJECTS_DIR="{{ joinPath .chezmoi.homeDir "Developer" "Projects" }}"

# 2. 如果标签包含 "work"，则引入工作相关的 Secret
{{ if contains "work" $tags -}}
export GITHUB_TOKEN="{{ onepasswordRead "WorkGitHubToken" }}"
{{- end }}

# 3. 动态别名：如果系统有 bat 就用 bat，否则用 cat
alias cat="{{ if lookPath "bat" }}bat{{ else }}cat{{ end }}"
```

### 💡 几个使用建议：

1.  **善用 `-` 控制空白**：在 `{{-` 或 `-}}` 中加入减号，可以移除模板渲染产生的多余换行和空格，保持生成的配置文件整洁。
2.  **本地调试**：使用 `chezmoi execute-template` 命令来即时查看模板渲染效果，无需执行 `apply`。
    *   `chezmoi execute-template '{{ .chezmoi.os }}'`
3.  **分块模板**：如果配置极其复杂，建议将常用的片段放在 `.chezmoitemplates/` 目录下，使用 `{{ template "name" . }}` 进行复用。

你目前是在为哪个具体的软件（如 Zsh, Neovim, SSH）编写模板吗？如果有具体的配置痛点，我可以为你提供针对性的组合方案。
