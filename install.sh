#!/bin/bash

COMMANDS="wget zsh git"
OS_CENTOS='centos'
OS_UBUNTU='ubuntu'
OSNAME=`grep '^ID=' /etc/os-release | awk -F'"' '{print $2}'`

ZSHELL=`grep zsh /etc/shells`
MYNAME=`whoami`

#=====================
# check command
#=====================

function installCommand()
{
        if [[ ! -n $1 ]]; then
                echo "install command faild"
                exit 1
        fi

        case $OSNAME in
        $OS_CENTOS)
                sudo yum install -y $1
        ;;
        $OS_UBUNTU)
                sudo apt install -y $1
        ;;
        *)
                echo "other os"
        esac
}

for CMD in $COMMANDS
do
        hash $CMD &>/dev/null
        if [[ $? -ne 0 ]]
        then
                installCommand $CMD
        fi
        continue
done

#=====================
# config zsh/zplug
#=====================
if [ -f ~/.zshrc ]; then
  mkdir -p ~/zsh-config/ && cp ~/.zshrc ~/zsh-config/zshrc
fi
if [ -d ~/.zplug ]; then 
  mkdir -p ~/zsh-config/ && mv ~/.zplug ~/zsh-config/zplug
fi 

export ZPLUG_HOME=~/.zplug
git clone https://github.com/zplug/zplug $ZPLUG_HOME &> /dev/null

cat > ~/.zshrc << EOF
# Check if zplug is installed

source ~/.zplug/init.zsh

# Misc
export EDITOR=vim
export GIT_EDITOR="${EDITOR}"
export PATH=$ZPLUG_HOME/bin:$PATH
export PAGER="most"
export LANG="en_US.UTF-8"

# History config
HISTSIZE=10000
SAVEHIST=10000
HISTFILE=$ZPLUG_HOME/zsh_history
setopt append_history
setopt share_history
setopt long_list_jobs
setopt hist_expire_dups_first
setopt hist_ignore_dups
setopt hist_ignore_all_dups
setopt hist_ignore_space
setopt hist_find_no_dups
setopt hist_reduce_blanks
setopt hist_verify
setopt hist_no_store
setopt interactivecomments
zstyle ':completion:*' rehash true

# Key binds
bindkey '\eOA'    history-substring-search-up
bindkey '\eOB'    history-substring-search-down
bindkey "\e[1;5D" backward-word
bindkey "\e[1;5C" forward-word
bindkey  "^[[H"   beginning-of-line
bindkey  "^[[F"   end-of-line

# Zplug plugins
zplug "zsh-users/zsh-completions"
zplug "zsh-users/zsh-history-substring-search"
zplug "zsh-users/zsh-syntax-highlighting"
zplug "zsh-users/zsh-autosuggestions"
zplug "zplug/zplug", hook-build:'zplug --self-manage'
zplug "supercrabtree/k"
zplug "b4b4r07/enhancd", use:init.sh
zplug "lib/completion", from:oh-my-zsh
zplug "plugins/colored-man-pages", from:oh-my-zsh
zplug "plugins/man", from:oh-my-zsh
zplug "plugins/sudo", from:oh-my-zsh
zplug "plugins/encode64", from:oh-my-zsh
zplug 'plugins/extract', from:oh-my-zsh
zplug "themes/half-life", from:oh-my-zsh, as:theme
# docker
zplug "tcnksm/docker-alias", use:zshrc
zplug 'plugins/docker', from:oh-my-zsh
zplug 'plugins/docker-compose', from:oh-my-zsh
# systemd
zplug 'plugins/systemd', from:oh-my-zsh
# z 
zplug 'plugins/z', from:oh-my-zsh

# git/php/npm
# zplug 'plugins/git', from:oh-my-zsh
# zplug 'plugins/composer', from:oh-my-zsh
# zplug 'plugins/npm', from:oh-my-zsh

zplug "junegunn/fzf"
zplug "junegunn/fzf-bin", \
    from:gh-r, \
    as:command, \
    rename-to:fzf, \
    use:"*linux*amd64*"
source $ZPLUG_HOME/repos/junegunn/fzf/shell/completion.zsh
source $ZPLUG_HOME/repos/junegunn/fzf/shell/key-bindings.zsh

if zplug check b4b4r07/enhancd; then
    export ENHANCD_FILTER=fzf-tmux
fi

# Install packages that have not been installed yet
if ! zplug check --verbose; then
    printf "Install? [y/N]: "
    if read -q; then
        echo; zplug install
    else
        echo
    fi
fi
zplug load
EOF


#=====================
# switch zsh
#=====================
sudo usermod -s $ZSHELL $MYNAME
$ZSHELL