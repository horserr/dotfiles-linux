if status is-interactive; and command -q tmux
    abbr -a t tmux new-session
    abbr -a tt tmux new-session -s
    abbr -a ta tmux attach
    abbr -a tls tmux list-sessions
    abbr -a tk tmux kill-session -t
    abbr -a tkill tmux kill-server
    abbr -a tmv tmux move-window -s -t
    abbr -a tlsk tmux list-keys -N

    # 1. 基础排除：如果在 tmux 内部或 VS Code 中，则不运行计数逻辑
    if not set -q TMUX; and test "$TERM_PROGRAM" != vscode

        # 2. SSH 依然保持自动进入（这是最稳妥的保命符）
        if set -q SSH_TTY
            tmux attach-session -t remote 2>/dev/null; or tmux new-session -s remote

            # 3. 本地环境：执行命令计数
        else
            # 初始化全局变量（仅在当前会话有效）
            set -g SESSION_CMD_COUNT 0

            # 定义监听函数
            function tmux_reminder_logic --on-event fish_postexec
                # 排除空命令或 tmux 相关的命令本身
                set -l last_cmd (string split " " -- $argv[1])[1]
                if test -z "$last_cmd"; or test "$last_cmd" = tmux; or test "$last_cmd" = t
                    return
                end

                # 计数累加
                set SESSION_CMD_COUNT (math $SESSION_CMD_COUNT + 1)

                # 到达 5 次时提醒
                if test "$SESSION_CMD_COUNT" -eq 5
                    echo (set_color yellow)"━━━ 💡 效率提醒 ━━━"(set_color normal)
                    echo "你已在当前会话执行了 $SESSION_CMD_COUNT 条命令。"
                    echo "建议开启 tmux 以获得更好的会话持久化能力。"
                    echo "输入 "(set_color -u cyan)"t"(set_color normal)" 快速进入，或继续操作。"

                    # 定义一个临时别名，方便快速进入
                    alias t="tmux attach-session -t local 2>/dev/null; or tmux new-session -s local"
                end
            end
        end
    end
end
