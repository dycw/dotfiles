#!/usr/bin/env sh

################################################################################
# apt-get
################################################################################

_is_missing_apt() {
  if dpkg -s $1 >/dev/null 2>&1; then
    false
  else
    true
  fi
  return
}

_install_apt() {
  sudo apt-get update
  sudo apt-get install $1 --yes
}

_ensure_apt() {
  if _is_missing_apt $1; then
    _install_apt $1
  fi
}

_ensure_apt bat
_ensure_apt curl
_ensure_apt curl
_ensure_apt fd-find
_ensure_apt fzf
_ensure_apt g++      # ?
_ensure_apt gcc      # ?
_ensure_apt gfortran # scipy
_ensure_apt git
_ensure_apt htop
_ensure_apt i3
_ensure_apt libatlas-base-dev # scipy
_ensure_apt libblas-dev       # scipy
_ensure_apt libblas3          # scipy
_ensure_apt liblapack-dev     # scipy
_ensure_apt liblapack3        # scipy
_ensure_apt tmux
_ensure_apt vim
_ensure_apt xclip

_ensure_apt_from_repository() {
  if _is_missing_apt $1; then
    sudo add-apt-repository $2 --yes
    _install_apt $2
  fi
}

_ensure_apt_from_repository lyx ppa:lyx-devel/release
_ensure_apt_from_repository pdfarranger ppa:linuxuprising/apps

if _is_missing_apt nordvpn; then
  filename="nordvpn-release_1.0.0_all.deb"
  wget https://repo.nordvpn.com/deb/nordvpn/debian/pool/main/$filename -P /tmp
  sudo apt-get install /tmp/$filename
  _install_apt nordvpn
fi

if _is_missing_apt speedtest; then
  sudo apt-get install gnupg1 apt-transport-https dirmngr
  export INSTALL_KEY=379CE192D401AB61
  sudo apt-key adv --keyserver keyserver.ubuntu.com --recv-keys $INSTALL_KEY
  echo "deb https://ookla.bintray.com/debian generic main" | sudo tee /etc/apt/sources.list.d/speedtest.list
  _install_apt speedtest
fi

###############################################################################
# snap
###############################################################################

_is_missing_snap() {
  if snap list | grep -q $1; then
    false
  else
    true
  fi
  return
}

_install_snap() {
  sudo snap install "$@"
}

_ensure_snap() {
  if _is_missing_snap $1; then
    _install_snap $1
  fi
}

_ensure_snap spotify
_ensure_snap telegram-desktop

if _is_missing_snap pycharm-professional; then
  _install_snap pycharm-professional --classic
fi

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
    echo "[user]\n  name = $name\n  email = $email\n" >>$path
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
      if command -v xclip >/dev/null 2>&1; then
        xclip -sel clip <$key
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
    if command -v git >/dev/null 2>&1; then
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
  if ! command -v conda >/dev/null 2>&1; then
    echo "$(date '+%F %T'): conda not found; installing..."
    case $(uname) in
    Linux*)
      desc="Linux"
      ;;
    *)
      echo "$(date '+%F %T'): unrecognized uname = $(uname); exiting..."
      exit 1
      ;;
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
