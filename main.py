#!/usr/bin/env python3
from pathlib import Path
from logging import getLogger
from logging import basicConfig
from subprocess import check_call
from shutil import which
print("hi")

basicConfig(
        format="{asctime} | {levelname:8} | {message}", datefmt="%Y-%m-%d %H:%M:%S", style="{", level="DEBUG"
)
_LOGGER=getLogger(__name__)
_THIS_FILE=Path(__file__)
_THIS_DIR=_THIS_FILE.parent
# install zoom



def main()->None:
    _install_git()
    _install_zoom()

def _install_git()->None:
    if which('git'):
        _LOGGER.debug("'git' already installed")
    else:
        _LOGGER.info("Installing 'git'...")
        _apt_install('git')
        if not which('git'):
            raise RuntimeError("'zoom' still not installed")
    for filename in ['config', 'ignore']:
        _setup_symlink(f"~/.config/git/{filename}", _THIS_DIR.joinpath(f'git/{filename}'))



def _setup_symlink(path_from:Path|str,path_to:Path|str,/)->None:
    path_from, path_to = [Path(p).expanduser() for p in [path_from ,path_to]]
    if path_from.is_symlink and (path_from.resolve()==path_to.resolve()):
        _LOGGER.debug("%r is already a symlink to %r", str(path_from),str(path_to))
        return
    _LOGGER.info("Symlinking %r -> %r", str(path_from),str(path_to))
    path_from.parent.mkdir(parents=True,exist_ok=True)
    path_from.symlink_to(path_to)


def _install_zoom()->None:
    if which('zoom'):
        _LOGGER.debug("'zoom' already installed")
        return
    _LOGGER.info("Installing 'zoom'...")
    check_call('sudo apt -y install libxcb-xinerama0 libxcb-xtest0 libxcb-cursor0', shell=True)
    check_call('sudo dpkg -i zoom_amd64.deb' , shell=True)
    if not which('zoom'):
        raise RuntimeError("'zoom' still not installed")

# utilities

def _apt_install(package:str,/)->None:
    _LOGGER.info("Updating 'apt'...")
    check_call('sudo apt -y update', shell=True)
    _LOGGER.info("Installing %r...", packagek)
    check_call(f'sudo apt -y install {package}', shell=True)

# main

main()
