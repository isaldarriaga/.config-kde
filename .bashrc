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

# ---------------------------------------------------

# k3s
export KUBECONFIG=/etc/rancher/k3s/k3s.yaml

# my editor
export EDITOR=nvim
export VISUAL=nvim

# distant
export PATH=$PATH:~/.local/bin

# fonts
export LANG=en_US.UTF-8
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
alias v=lvim
alias vi=lvim
alias vim=lvim

# other
alias tree="xplr"
alias warmup="typeracer"

# Advanced command-not-found hook
if [ -f /etc/arch-release ]; then
	source /usr/share/doc/find-the-command/ftc.bash
fi

# Setup apps at ~/.config

CUR_DATETIME=$(date '+%Y-%m-%dT%H:%M:%S')
MY_CONFIG_PATH="/home/$USER/repos/.dotfiles/.config"

HOME_CONFIG_PATH=/home/$USER/.config

# easy setups
for APP in alacritty starship
do
	APP_CONFIG_PATH=$HOME_CONFIG_PATH/$APP
	MY_APP_CONFIG_PATH=$MY_CONFIG_PATH/$APP/

	MSG_CHECKING="\n🕰 Checking $APP config.."
	MSG_SYMLINK_CREATING="\t🕰 Creating symlink to $APP config.."
	MSG_SYMLINK_EXISTS="\t🔴 Symlink already exist\n\t\tpath: $APP_CONFIG_PATH"
	MSG_SYMLINK_COMPLETE="\t✅ Complete.\n\t$APP config at: $APP_CONFIG_PATH"

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

# complex setups
APP=nvim

# ACTIONS: backup | install | keep
ACTION=${1:-keep}

# DISTROS: lazyvim | nvchad ..
DISTRO=${2:-"lazyvim"}

APP_CONFIG_PATH=$HOME_CONFIG_PATH/$APP
APP_SHARE_PATH=~/.local/share/$APP
APP_STATE_PATH=~/.local/state/$APP
APP_CACHE_PATH=~/.cache/$APP

case "$ACTION" in
"keep")
	if [ -L $APP_CONFIG_PATH ]
	then
		echo -e "\n✅ Keeping $APP ($DISTRO) config\n\tsymlink: $APP_CONFIG_PATH"
	else
		if [ -d $APP_CONFIG_PATH ]
		then
			echo -e "\t✅ Keeping $APP ($DISTRO) config\n\t\tfolder: $APP_CONFIG_PATH"
		else
			echo -e "\t🔴 $APP ($DISTRO) config to $ACTION not found.\n\t\tChange ACTION from $ACTION to 'install'"
		fi
	fi
	;;

"backup")
    for DIR in $APP_CONFIG_PATH $APP_SHARE_PATH $APP_STATE_PATH $APP_CACHE_PATH
    do
		echo -e "\n🕰 Backing up $APP ($DISTRO)\n\tat: $DIR.."

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

	MSG_CALLING="\t🕰 Calling $APP ($DISTRO).."
	MSG_CALLING_COMPLETE="\t\t✅ Complete.\n\t\t\tPlugins Setup"

	MSG_SYMLINK_CREATING="\t🕰 Creating symlink..\n\t\tfrom: $MY_CONFIG_PATH/$DISTRO/\n\t\tto: $APP_CONFIG_PATH"
	MSG_SYMLINK_EXISTS="\t\t🔴 Symlink to config already exist.\n\t\t\tChange ACTION from $ACTION to 'backup' or 'keep'"
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
			nvim
			echo -e $MSG_CALLING_COMPLETE
		fi

		LUA_CUSTOM_PATH=lua/custom
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

# la
