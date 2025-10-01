if status is-interactive
    # Commands to run in interactive sessions can go here



    # fzf
    fzf --fish | source




    # fish config
    function fish_config
        edit ~/.config/fish/config.fish
    end

    # neovim
    if type -q nvim
    set -gx EDITOR nvim
    set -gx VISUAL nvim

	    function n
		    nvim
		 end

	end
    # vi
    fish_vi_key_bindings


    # vim
    if type -q vim
	    if not type -q nvim
		        set -gx EDITOR vim
			    set -gx VISUAL vim
	end



	    function v
		    vim
		 end

	end
end
