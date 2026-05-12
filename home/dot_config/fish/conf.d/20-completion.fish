if status is-interactive
    if type -q zoxide
        zoxide init fish | source
    end

    if command -sq pixi
        pixi completion --shell fish | source
    end

    if command -sq chezmoi
        chezmoi completion fish | source
    end

    # github cli
    if command -sq gh
        gh completion -s fish | source
    end
end
