#!/bin/bash
# https://guojing.io
# https://github.com/jotyGill/quickz-sh

COMMANDS="wget zsh git"
ZSHELL=`grep zsh /etc/shells`
MYNAME=`whoami`

# install zsh/git/wget
if command -v zsh &> /dev/null && command -v git &> /dev/null && command -v wget &> /dev/null; then
        echo -e "ZSH and Git are already installed\n"
else
	if sudo apt install -y $COMMANDS || sudo dnf install -y $COMMANDS || sudo yum install -y $COMMANDS || sudo brew install $COMMANDS ; then
		echo -e "ZSH and Git Installed\n"
	else
		echo -e "Can't install ZSH or Git\n" && exit
	fi
fi

# config zsh/zplug
if [ -f ~/.zshrc ]; then
  echo -e "Backed up the current .zshrc to ~/zsh-config/zshrc-backup-date\n"
  mkdir -p ~/zsh-config/ && cp ~/.zshrc ~/zsh-config/zshrc-backup-$(date +"%Y-%m-%d")
fi

if [ -d ~/.zplug ]; then 
  echo -e "Backed up the current .zplug/ to ~/zsh-config/zplug\n"
  mkdir -p ~/zsh-config/ && mv ~/.zplug ~/zsh-config/zplug
fi 


echo -e "Installing zplug\n"
export ZPLUG_HOME=~/.zplug
if git clone https://github.com/zplug/zplug $ZPLUG_HOME ; then
        echo -e "Installed zplug\n"
fi

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

# external plugins
zplug "zsh-users/zsh-completions"
zplug "zsh-users/zsh-history-substring-search"
zplug "zsh-users/zsh-syntax-highlighting"
zplug "zsh-users/zsh-autosuggestions"
zplug "zplug/zplug", hook-build:'zplug --self-manage'
zplug "supercrabtree/k"
zplug "b4b4r07/enhancd", use:init.sh
zplug "themes/half-life", from:oh-my-zsh, as:theme

# oh-my-zsh plugins
zplug "lib/completion", from:oh-my-zsh
zplug "plugins/colored-man-pages", from:oh-my-zsh
zplug "plugins/man", from:oh-my-zsh
zplug "plugins/sudo", from:oh-my-zsh
zplug "plugins/encode64", from:oh-my-zsh
zplug 'plugins/extract', from:oh-my-zsh
zplug 'plugins/docker', from:oh-my-zsh
zplug 'plugins/docker-compose', from:oh-my-zsh
zplug 'plugins/systemd', from:oh-my-zsh
zplug 'plugins/z', from:oh-my-zsh

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

# Install plugins if there are plugins that have not been installed
if ! zplug check --verbose; then
    printf "Install? [y/N]: "
    if read -q; then
        echo; zplug install
    else
        echo
    fi
fi

# Then, source plugins and add commands to $PATH
zplug load
EOF

# source .zshrc
echo -e "\nSudo access is needed to change default shell\n"
if chsh -s $(which zsh) && /bin/zsh; then
	echo -e "Installation Successful, exit terminal and enter a new session"
else
	echo -e "Something is wrong"
fi
exit