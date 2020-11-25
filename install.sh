#!/usr/bin/env sh

################################################################################
# apt-get
################################################################################

_maybe_apt_get_install() {
  if ! dpkg -s $1 > /dev/null 2>&1; then
    sudo apt-get install $1 --yes
  fi
}

_maybe_apt_get_install bat
_maybe_apt_get_install curl
_maybe_apt_get_install fd-find
_maybe_apt_get_install fzf
_maybe_apt_get_install g++  # ?
_maybe_apt_get_install gcc  # ?
_maybe_apt_get_install gfortran  # scipy
_maybe_apt_get_install git
_maybe_apt_get_install htop
_maybe_apt_get_install i3
_maybe_apt_get_install libatlas-base-dev  # scipy
_maybe_apt_get_install libblas-dev  # scipy
_maybe_apt_get_install libblas3  # scipy
_maybe_apt_get_install liblapack-dev  # scipy
_maybe_apt_get_install liblapack3  # scipy
_maybe_apt_get_install tmux
_maybe_apt_get_install vim
_maybe_apt_get_install xclip

if ! dpkg -s lyx > /dev/null 2>&1; then
  sudo add-apt-repository ppa:lyx-devel/release --yes
  sudo apt-get install lyx --yes
fi

if ! dpkg -s nordvpn > /dev/null 2>&1; then
  filename="nordvpn-release_1.0.0_all.deb"
  wget https://repo.nordvpn.com/deb/nordvpn/debian/pool/main/$filename -P /tmp
  sudo apt-get install /tmp/$filename
  sudo apt-get update
  sudo apt-get install nordvpn --yes
fi

if ! dpkg -s pdfarranger > /dev/null 2>&1; then
  sudo add-apt-repository ppa:linuxuprising/apps
  sudo apt-get update
  sudo apt-get install pdfarranger --yes
fi

###############################################################################
# snap
###############################################################################

_maybe_snap_install() {
  if ! snap list | grep -q $1; then
     sudo snap install $1
  fi
}

_maybe_snap_install pycharm-community
_maybe_snap_install spotify
_maybe_snap_install telegram-desktop

################################################################################
# local files
################################################################################
_create_gitconfig_local() {
  path=~/.config/git/config.local
  if ! [ -f $path ]; then
    echo "$(date '+%F %T'): $path does not exist; creating..."
    printf "user.name = "
    read name
    printf "user.email = "
    read email
    mkdir -p "$(dirname $path)"
    echo "[user]\n  name = $name\n  email = $email\n" >> $path
    echo "$(date '+%F %T'): $path created"
  fi
}

_create_gitconfig_local

_create_ssh_key() {
  private=~/.ssh/id_rsa
  public=$private.pub
  if ! [ -f $public ]; then
    echo "$(date '+%F %T'): $public does not exist; creating..."
    ssh-keygen -t rsa -b 4096 -C "d.wan@icloud.com"
    ssh-agent -s
    ssh-add -K $private
    echo "$(date '+%F %T'): $public created; copying..."
  fi
}

_create_ssh_key

_clone_dotfiles() {
  dotfiles=~/.dotfiles
  key=~/.ssh/id_rsa.pub
  if ! [ -d $dotfiles ]; then
    echo "$(date '+%F %T'): $dotfiles does not exist; cloning..."
    while true; do
      if command -v xclip > /dev/null 2>&1; then
        xclip -sel clip < $key
      else
        echo "$(date '+%F %T'): expected xclip to be found; aborting..."
        exit 1
      fi
      echo "$(date '+%F %T'): $key copied; please head to https://github.com/settings/keys; enter 'y' when back"
      read input
      if [ $input = y ]; then
        break
      fi
    done
    if command -v git > /dev/null 2>&1; then
      git clone git@github.com:dycw/dotfiles.git $dotfiles
    else
      echo "$(date '+%F %T'): expected git to be found; aborting..."
      exit 1
    fi
  fi
}

_clone_dotfiles

################################################################################
# symlinks
################################################################################

_create_one_symlink() {
  from=$1
  to=$2
  mkdir -p "$(dirname $to)"
  ln -s $from $to
}

_process_one_symlink() {
  from=$1
  to=$2
  if [ -L $to ]; then
    target=$(readlink $to)
    if ! [ $target = $from ]; then
      echo "$(date '+%F %T'): Overwriting $to -> ($target -> $to)"
      rm $to
      _create_one_symlink $from $to
    fi
  else
    echo "$(date '+%F %T'): Symlinking $from -> $to..."
    _create_one_symlink $from $to
  fi
}

_process_all_symlinks() {
  _process_one_symlink ~/.dotfiles/condarc ~/.condarc
  _process_one_symlink ~/.dotfiles/git/config ~/.config/git/config
  _process_one_symlink ~/.dotfiles/git/ignore ~/.config/git/ignore
  _process_one_symlink ~/.dotfiles/i3 ~/.config/i3/config
  _process_one_symlink ~/.dotfiles/ipython/ipython_config.py ~/.ipython/profile_default/ipython_config.py
  _process_one_symlink ~/.dotfiles/jupyter_notebook_config.py ~/.jupyter/jupyter_notebook_config.py
  _process_one_symlink ~/.dotfiles/tmux.conf ~/.tmux.conf
  _process_one_symlink ~/.dotfiles/vimrc ~/.vimrc
  _process_one_symlink ~/.dotfiles/zsh/zshenv ~/.zshenv
  _process_one_symlink ~/.dotfiles/zsh/zshrc ~/.zshrc

  for filename in ~/.dotfiles/ipython/startup/*.py; do
    _process_one_symlink "$filename" "$HOME/.ipython/profile_default/startup/$(basename $filename)"
  done
}

_process_all_symlinks

################################################################################
# conda
################################################################################
_install_conda() {
  if ! command -v conda > /dev/null 2>&1; then
    echo "$(date '+%F %T'): conda not found; installing..."
    case $(uname) in
      Linux*)
        desc="Linux";;
      *)
        echo "$(date '+%F %T'): unrecognized uname = $(uname); exiting..."
        exit 1;;
    esac
    filename="Miniconda3-latest-$desc-x86_64.sh"
    wget https://repo.anaconda.com/miniconda/$filename -P /tmp
    full_filename=/tmp/$filename
    chmod u+x $full_filename
    $full_filename
  fi
}

_install_conda

###############################################################################
# zsh
###############################################################################
_install_zsh() {
  if ! command -v zsh >/dev/null 2>&1; then
    _apt_get_install zsh
    chsh -s /usr/bin/zsh
    echo "$(date '+%F %T'): Exiting; please restart your system"
    return
  fi
}

_install_zsh

# zinit (after conda, zsh)
_install_zinit() {
  if ! [ -d ~/.zinit ]; then
    echo "$(date '+%F %T'): zinit not found; installing..."
    sh -c "$(curl -fsSL https://raw.githubusercontent.com/zdharma/zinit/master/doc/install.sh)"
    echo "$(date '+%F %T'): zinit installed"
  fi
}

_install_zinit
