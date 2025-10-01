if status is-interactive
    # Commands to run in interactive sessions can go here


    # nvim
    set -gx EDITOR vim
    set -gx VISUAL vim

    # fzf
    fzf --fish | source

    # fish config
    function fish_config
	    edit ~/.config/fish/config.fish
	end

    # vi
    fish_vi_key_bindings
end
