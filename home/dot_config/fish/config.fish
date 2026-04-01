# WSL SSH Agent Bridge
if status is-interactive; and string match -qi "*microsoft*" </proc/sys/kernel/osrelease

    set -gx SSH_AUTH_SOCK "$HOME/.ssh/agent.sock"

    # 核心修改：先判断 ss 命令是否存在，再执行逻辑
    if command -sq ss
        if not ss -lnx | grep -q "$SSH_AUTH_SOCK"
            rm -f "$SSH_AUTH_SOCK"
            set -l npiperelay_path (command -v npiperelay.exe)

            if test -n "$npiperelay_path"
                nohup socat UNIX-LISTEN:"$SSH_AUTH_SOCK",fork \
                    EXEC:"$npiperelay_path -ei -s //./pipe/openssh-ssh-agent",nofork >/dev/null 2>&1 &
                disown
            end
        end
    else
        # 如果没有 ss，也可以尝试用 test -S 判断 socket 文件是否存在（虽然没 ss 准确）
        if not test -S "$SSH_AUTH_SOCK"
            # 这里可以留空或者尝试基础逻辑
        end
    end
end
