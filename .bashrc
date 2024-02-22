# If not running interactively, don't do anything
[[ $- != *i* ]] && return

# Replace ls with exa
LS='exa -al --color=always --group-directories-first'         # preferred listing
LA='exa -al --color=always --group-directories-first'         # all files and dirs
LL='exa -l --color=always --group-directories-first --icons'  # long format
LT='exa -aT --color=always --group-directories-first --icons' # tree listing
LDOT="exa -a | egrep '^\.'"                                   # only dot files

case $(tty) in /dev/tty[0-9]*)
	echo -e "tty detected!"
	setfont -d
	showconsolefont

	alias ls="$LS"
	alias la="$LA"
	alias ll="$LL"
	alias lt="$LT"
	alias l.="$LDOT"
	;;
esac

case $(tty) in /dev/pts/[0-9]*)
	if [ $(basename $SHELL) = "bash" ]; then
		eval "$(starship init bash)"
	elif [ $(basename $SHELL) = "fish" ]; then
		starship init fish | source
	fi
	export STARSHIP_CONFIG=~/.config/starship/starship.toml

	alias ls="$LS --icons"
	alias la="$LA --icons"
	alias ll="$LL --icons"
	alias lt="$LT --icons"
	alias l.="$LDOT"
	;;
esac

echo -e -n "\x1b[\x33 q" # Blinking underline
# man coloring
export LESS_TERMCAP_mb=$'\e[1;32m'
export LESS_TERMCAP_md=$'\e[1;32m'
export LESS_TERMCAP_me=$'\e[0m'
export LESS_TERMCAP_se=$'\e[0m'
export LESS_TERMCAP_so=$'\e[01;33m'
export LESS_TERMCAP_ue=$'\e[0m'
export LESS_TERMCAP_us=$'\e[1;4;31m'

# Aliases
alias ip="ip -color"
alias egrep='grep -E --color=auto'
alias fgrep='grep -F --color=auto'
alias grep='grep --color=auto'
alias grubup="sudo update-grub"
alias hw='hwinfo --short'
alias psmem10='ps auxf | sort -nr -k 4 | head -10'
alias psmem='ps auxf | sort -nr -k 4'
alias tarnow='tar -acf '
alias untar='tar -zxvf '
alias wget='wget -c '
alias less="less --use-color"

# Get the error messages from journalctl
alias jctl="journalctl -p 3 -xb"
alias journalctl="jctl"

# dot files repo
HOME_PATH="/home/$USER"
REPOS_PATH="$HOME_PATH/repos"
DOTFILES_PATH="$REPOS_PATH/dotfiles"
HOME_SHARE_PATH="$HOME_PATH/.local/share"
BASHRC_PATH="$HOME_PATH/.bashrc"

# ACTIONS: backup | install | keep
DEFAULT_ACTION="keep"
# DISTROS: lazyvim | nvchad | lunarvim | astronvim
DEFAULT_DISTRO="helix"
# CHANNEL
#   lunarvim: release | nightly
#   astronvim: stable | nightly
DEFAULT_CHANNEL="release"

case "$DEFAULT_DISTRO" in
  "helix")
    DEFAULT_EDITOR=hx
    ;;
  "lazyvim")
    DEFAULT_EDITOR=nvim
    ;;
  "nvchad")
    DEFAULT_EDITOR=nvim
		LUA_CUSTOM_PATH=lua/custom
		;;
  "lunarvim")
    DEFAULT_EDITOR=lvim
    ;;
  "astronvim")
    DEFAULT_EDITOR=nvim
		LUA_CUSTOM_PATH=lua/user
    ;;
esac

# quick edits

alias cdrepos="cd $REPOS_PATH" # cd repos files
alias erepos=$(echo "cdrepos && $DEFAULT_EDITOR .") # edit at repos folder

alias cddot="cd $DOTFILES_PATH" # cd dot files
alias edot=$(echo "cddot && $DEFAULT_EDITOR .") # edit at dotfiles folder

alias cddistro="cd $HOME_SHARE_PATH/$DEFAULT_APP" # cd distro folder (installed path)
alias edistro=$(echo "cddot && $DEFAULT_EDITOR .") # edit at distro folder

alias cdbash=cd $HOME_
alias ebash=$(echo "$DEFAULT_EDITOR $BASHRC_PATH") # edit .bashrc
alias sbash="source $BASHRC_PATH" # source .bashrc

alias ebak="source $BASHRC_PATH backup $DEFAULT_DISTRO" # editor backup
alias einstall="source $BASHRC_PATH install $DEFAULT_DISTRO $DEFAULT_CHANNEL" # editor install
alias ekeep="source $BASHRC_PATH keep $DEFAULT_DISTRO" # editor keep

# ---------------------------------------------------

# k3s
export KUBECONFIG=/etc/rancher/k3s/k3s.yaml

# my editor
export EDITOR=$DEFAULT_EDITOR
export VISUAL=$DEFAULT_EDITOR

# distant
export PATH=$PATH:~/.local/bin

# locales (fix fonts)
export LC_ALL=C.UTF-8
export LANG=en_US.UTF-8
export LANGUAGE=en_US.UTF-8
export LC_CTYPE=en_US.UTF-8

# ALIASES

# containers
alias mk="minikube"
alias k="sudo k3s kubectl"

alias pm="podman"
alias db="distrobox"

# git
alias lg="lazygit"
alias gu="gitui"

# editor
alias v=nvim
alias vi=nvim
alias vim=nvim

# other
alias tree="xplr"
alias warmup="typeracer"

# Advanced command-not-found hook
if [ -f /etc/arch-release ]; then
	source /usr/share/doc/find-the-command/ftc.bash
fi

# Setup apps at ~/.config

CUR_DATETIME=$(date '+%Y-%m-%dT%H:%M:%S')
MY_CONFIG_PATH="$DOTFILES_PATH/config"
HOME_CONFIG_PATH="$HOME_PATH/.config"

# easy setups
for EASY_APP in alacritty starship helix
do
	APP_CONFIG_PATH=$HOME_CONFIG_PATH/$EASY_APP
	MY_APP_CONFIG_PATH=$MY_CONFIG_PATH/$EASY_APP/

	MSG_CHECKING="\n🕰 Checking $EASY_APP config.."
	MSG_SYMLINK_EXISTS="\t🟢 Symlink already exist\n\t\tat: $APP_CONFIG_PATH"
	MSG_SYMLINK_CREATING="\t🕰 Creating symlink to config.."
	MSG_SYMLINK_COMPLETE="\t\t✅ Complete.\n\t\t\tconfig at: $APP_CONFIG_PATH"

	echo -e $MSG_CHECKING

  if ! [ -L $APP_CONFIG_PATH ]
  then
		echo -e $MSG_SYMLINK_CREATING
		ln -s $MY_APP_CONFIG_PATH $APP_CONFIG_PATH
		echo -e $MSG_SYMLINK_COMPLETE
	else
		echo -e $MSG_SYMLINK_EXISTS
	fi
done

# phased setups

ACTION=${1:-"$DEFAULT_ACTION"}
DISTRO=${2:-"$DEFAULT_DISTO"}
CHANNEL=${3:-"$DEFAULT_CHANNEL"}

APP=$DEFAULT_EDITOR

MY_APP_CONFIG_PATH=$MY_CONFIG_PATH/$DISTRO/

APP_CONFIG_PATH=$HOME_CONFIG_PATH/$APP
APP_SHARE_PATH=$HOME_SHARE_PATH/$APP
APP_STATE_PATH=$HOME_CONFIG_PATH/.local/state/$APP
APP_CACHE_PATH=$HOME_CONFIG_PATH/.cache/$APP

case "$ACTION" in
"keep")
	echo -e "\n🕰 Keeping $APP ($DISTRO) config.."
	
  MSG_SYMLINK_CREATING="\t🕰 Creating symlink to $APP ($DISTRO) config.."
	MSG_SYMLINK_EXISTS="\t🟢 Symlink already exist\n\t\tat: $APP_CONFIG_PATH"
	MSG_SYMLINK_COMPLETE="\t\t✅ Complete\n\t\t\tSymlink at: $APP_CONFIG_PATH\n\t\t\tTargets: $MY_APP_CONFIG_PATH"

	if ! [ -L $APP_CONFIG_PATH ] && ! [ -d $APP_CONFIG_PATH ]
	then
      echo -e $MSG_SYMLINK_CREATING
  		ln -s $MY_APP_CONFIG_PATH $APP_CONFIG_PATH
	  	echo -e $MSG_SYMLINK_COMPLETE
  fi

	if [ -L $APP_CONFIG_PATH ]
	then
		echo -e $MSG_SYMLINK_EXISTS
	else
		if [ -d $APP_CONFIG_PATH ]
		then
      echo -e "\t🟢 Folder detected (incomplete setup): $APP_CONFIG_PATH"

      if [ $LUA_CUSTOM_PATH == "" ]
      then
      	echo -e "\t\t🕰 backing up existing config folder.."
  			mv $APP_CONFIG_PATH{,-$CUR_DATETIME.bak}
  			echo -e "\t\t✅ Complete.\n\t\t\tMoved to: $APP_CONFIG_PATH-$CUR_DATETIME.bak"

      	echo -e $MSG_SYMLINK_CREATING
  			ln -s $MY_APP_CONFIG_PATH $APP_CONFIG_PATH
	  		echo -e $MSG_SYMLINK_COMPLETE
      else
      	echo -e $MSG_SYMLINK_CREATING
  			ln -s $MY_APP_CONFIG_PATH/$LUA_CUSTOM_PATH/ $APP_CONFIG_PATH/$LUA_CUSTOM_PATH
	  		echo -e $MSG_SYMLINK_COMPLETE
      fi
		else
			echo -e "\t🟡 Config not found.\n\t\tChange ACTION from $ACTION to 'install'"
		fi
	fi
	;;

"backup")
    echo -e "\n🕰 Backing up $APP ($DISTRO).."
    for DIR in $APP_CONFIG_PATH $APP_SHARE_PATH $APP_STATE_PATH $APP_CACHE_PATH
    do
      echo -e "\tat: $DIR.."
      if [ -L $DIR ]
      then
    	  echo -e "\t\t🕰 Removing existing symlink.."
  	  	rm $DIR
  			echo -e "\t\t\t✅ Complete.\n\t\t\t\tSymlink removed at: $DIR"
  		else
        if [ -d $DIR ]
        then
  				  echo -e "\t\t🕰 Moving existing config folder.."
  				  mv $DIR{,-$CUR_DATETIME.bak}
  				  echo -e "\t\t\t✅ Complete.\n\t\t\t\tMoved to: $DIR-$CUR_DATETIME.bak"
  			else
  				echo -e "\t\t🟡 There's no symlink or folder to backup.\n\t\t\tChange ACTION from $ACTION to 'install'"
  			fi
  		fi
  	done
	;;

"install")

	MSG_INSTALLING="\n🕰 Installing $APP ($DISTRO).."

	MSG_CLONING="\t🕰 Cloning repo.."
	MSG_CLONING_COMPLETE="\t\t✅ Complete.\n\t\t\tCloned at: $APP_CONFIG_PATH"

	MSG_SETTING_UP="\t🕰 Setting up.."
  MSG_SETTING_UP_COMPLETE="\t\t✅ Complete.\n\t\t\tSettings at: $APP_CONFIG_PATH (folder)"

	MSG_CALLING="\t🕰 Calling $APP ($DISTRO).."
	MSG_CALLING_COMPLETE="\t\t✅ Complete.\n\t\t\tPlugins Setup"

	MSG_SYMLINK_CREATING="\t🕰 Creating symlink..\n\t\tfrom: $MY_CONFIG_PATH/$DISTRO/ to: $APP_CONFIG_PATH"
	MSG_SYMLINK_EXISTS="\t🟢 Symlink already exist.\n\t\tChange ACTION from $ACTION to 'backup' or 'keep'"
	MSG_SYMLINK_COMPLETE="\t\t✅ Complete.\n\t\t\tsymlink at: $APP_CONFIG_PATH"

	echo -e $MSG_INSTALLING

	case "$DISTRO" in
	"lazyvim")
    if ! [ -L $APP_CONFIG_PATH ]
    then
			echo -e $MSG_SYMLINK_CREATING
			ln -s $MY_CONFIG_PATH/$DISTRO/ $APP_CONFIG_PATH
			echo -e $MSG_SYMLINK_COMPLETE

			echo -e $MSG_CALLING
			sleep 2
			nvim
			echo -e $MSG_CALLING_COMPLETE
		else
			echo -e $MSG_SYMLINK_EXISTS
		fi
		;;

	"nvchad")
    if ! [ -d $APP_CONFIG_PATH ]
    then
			echo -e $MSG_CLONING
			git clone -q https://github.com/NvChad/NvChad $APP_CONFIG_PATH --depth 1
			echo -e $MSG_CLONING_COMPLETE

			echo -e $MSG_CALLING
			sleep 2
      $(echo "$APP")
			echo -e $MSG_CALLING_COMPLETE
		fi

    if ! [ -L $APP_CONFIG_PATH/$LUA_CUSTOM_PATH ]
    then
			echo -e $MSG_SYMLINK_CREATING
			ln -s $MY_CONFIG_PATH/$DISTRO/$LUA_CUSTOM_PATH/ $APP_CONFIG_PATH/$LUA_CUSTOM_PATH
			echo -e $MSG_SYMLINK_COMPLETE/$LUA_CUSTOM_PATH
		else
			echo -e $MSG_SYMLINK_EXISTS
		fi
		;;

  "lunarvim")
    if ! [ -L $APP_CONFIG_PATH ]
    then
			echo -e $MSG_SETTING_UP
      case "$CHANNEL" in
        "release")
          LV_BRANCH='release-1.3/neovim-0.9' bash <(curl -s https://raw.githubusercontent.com/LunarVim/LunarVim/release-1.3/neovim-0.9/utils/installer/install.sh)
          ;;
        "nightly")
          bash <(curl -s https://raw.githubusercontent.com/lunarvim/lunarvim/master/utils/installer/install.sh)
          ;;
      esac
      echo -e $MSG_SETTING_UP_COMPLETE

      $(echo "$APP -v")

      $(echo "$APP -c checkhealth")
		else
			echo -e $MSG_SYMLINK_EXISTS
		fi
		;;

  "astronvim")
    
    if ! [ -d $APP_CONFIG_PATH ]
    then
			echo -e $MSG_CLONING
			git clone --depth 1 https://github.com/AstroNvim/AstroNvim $APP_CONFIG_PATH --depth 1
			echo -e $MSG_CLONING_COMPLETE

			echo -e $MSG_CALLING
      $(echo "$APP --headless +q")
			echo -e $MSG_CALLING_COMPLETE

      $(echo "$APP -v")

      $(echo "$APP -c checkhealth")
		fi

    if ! [ -L $APP_CONFIG_PATH/$LUA_CUSTOM_PATH ]
    then
			echo -e $MSG_SYMLINK_CREATING
			ln -s $MY_CONFIG_PATH/$DISTRO/$LUA_CUSTOM_PATH/ $APP_CONFIG_PATH/$LUA_CUSTOM_PATH
			echo -e $MSG_SYMLINK_COMPLETE/$LUA_CUSTOM_PATH
		else
			echo -e $MSG_SYMLINK_EXISTS
		fi
	  ;;
	esac
	;;

esac

# nvim bash completion
export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"                   # This loads nvm
[ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion" # This loads nvm bash_completion
. "$HOME/.cargo/env"
