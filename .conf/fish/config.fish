# ~/.config/fish/config.fish
#

if status is-interactive
    # Commands to run in interactive sessions go here

    alias ls 'ls --color=auto'
    alias grep 'grep --color=auto'

    # Fish doesn't use PS1 — define a prompt function instead
    # Uses fish's built-in $hostname variable instead of the external `hostname` command
    function fish_prompt
        echo -n '['(whoami)'@'$hostname' '(prompt_pwd -D 1)']\$ '
    end

    #source ~/.config/bash/bashrc  (fish equivalent, if needed, would be its own .fish file)

    # ─────────────────────────────────────────────
    # Monitor input
    # ─────────────────────────────────────────────

    function switch-monitor-to-dp
        ddcutil setvcp 60 15
    end

    alias change-monitor 'switch-monitor-to-dp'
    alias switch-display 'switch-monitor-to-dp'
    alias change-display 'switch-monitor-to-dp'
    alias change-monitor-15 'switch-monitor-to-dp'
    alias change-display-15 'switch-monitor-to-dp'
    alias change-monitor-hdmi 'switch-monitor-to-dp'
    alias change-display-hdmi 'switch-monitor-to-dp'
    alias dp 'switch-monitor-to-dp'

    function switch-monitor-to-hdmi
        ddcutil setvcp 60 17
    end

    alias hdmi 'switch-monitor-to-hdmi'

    # ─────────────────────────────────────────────
    # Pacman
    # ─────────────────────────────────────────────

    alias install 'sudo pacman -S --noconfirm'
    alias update 'sudo pacman -Syu --noconfirm'
    alias uninstall 'sudo pacman -Rns --noconfirm'

    alias cgpt 'carbonyl https://chatgpt.com/'

    # ─────────────────────────────────────────────
    # Config file shortcuts
    # ─────────────────────────────────────────────

    function _config_file
        switch $argv[1]
            case hyprland-lua hl
                echo "$HOME/.config/hypr/hyprland.lua"
            case waybar-conf
                echo "$HOME/.config/waybar/config"
            case waybar-css
                echo "$HOME/.config/waybar/style.css"
            case docker-css
                echo "$HOME/.config/nwg-dock-hyprland/style.css"
            case drawer-css drc
                echo "$HOME/.config/nwg-drawer/drawer.css"
            case bashrc script
                echo "$HOME/.config/bash/bashrc"
            case '*'
                echo $argv[1]
        end
    end

    # Open with nano
    function nano
        set -l target (_config_file $argv[1])
        command nano $target
    end

    # Open with Kate
    function kate
        set -l target (_config_file $argv[1])
        command kate $target &>/dev/null &
    end

    # Open with Code
    function code
        set -l target (_config_file $argv[1])
        command code $target &>/dev/null &
    end

    # ─────────────────────────────────────────────
    # Search function
    # ─────────────────────────────────────────────

    function search
        if test -z "$argv[1]"
            echo "Usage: search <name>"
            return 1
        end

        find "$HOME" -iname "*$argv[1]*" 2>/dev/null
    end

end
