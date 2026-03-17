if status is-interactive
    fish_vi_key_bindings
end

function proxy
    # 获取 Windows 宿主机 IP
    set -l host_ip (ip route show | grep default | awk '{print $3}')
    set -l port 7897

    switch $argv[1]
        case on
            set -gx http_proxy "http://$host_ip:$port"
            set -gx https_proxy "http://$host_ip:$port"
            set -gx all_proxy "socks5://$host_ip:$port"
            echo "代理已开启"
            echo "Windows IP: $host_ip"
            echo "Proxy Port: $port"
        case off
            set -e http_proxy
            set -e https_proxy
            set -e all_proxy
            echo "代理已关闭"
        case status
            echo "http_proxy  : $http_proxy"
            echo "https_proxy : $https_proxy"
        case '*'
            echo "使用方法: proxy [on|off|status]"
    end
end