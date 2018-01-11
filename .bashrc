#!/bin/bash
#
#  .bashrc
#
#  awdeorio's Bash customizations


### places ####################################################################
export NFSHOME=/net/trenton/w/awdeorio
export IFSHOME=/afs/umich.edu/user/a/w/awdeorio
export WWWHOME=/net/web/w/web/u/a/awdeorio
export WWWINFERNO=/net/web/w/web/inferno
export BACKUP=${NFSHOME}/backup/manzana/awdeorio
export EECS280=/afs/umich.edu/class/eecs280

# set umask for both scp and ssh
umask 002


### Aliases ###################################################################
alias g="git"
alias du="du -sh"
alias dusort="command du -s * .* | sort -n"
alias df="df -h"
alias cdd="cd .."
alias grep="grep --color"
alias egrep="egrep --color"
alias fgrep="fgrep --color"
alias zgrep="zgrep --color"
alias igrep="grep -i"
alias wcl="wc -l"
alias rmb='echo "rm -vf *~ .*~" && rm -vf *~ .*~'
alias rmt='[ -d ${HOME}/.Trash/ ] && echo "rm -rvf ${HOME}/.Trash/*" && rm -rvf ${HOME}/.Trash/*'
alias rmd='[ -d ${HOME}/Downloads/ ] && echo "rm -rvf ${HOME}/Downloads/*" && rm -rvf ${HOME}/Downloads/*'
alias rme='[ -d ${HOME}/Desktop/ ] && echo "rm -rvf ${HOME}/Desktop/*" && rm -rvf ${HOME}/Desktop/*'
alias latex='latex -halt-on-error'
alias dftp='ssh -R 19999:localhost:22'
function dftp-get { command scp -r -P19999 "$@" localhost: ; }
alias R='R --quiet --no-save'
alias grip='grip --norefresh --browser'
#NOTE: see later for ls options
alias whatismyip='curl ipinfo.io/ip'
alias weather='curl http://wttr.in/ann_arbor?Tn1'
alias weather3='curl http://wttr.in/ann_arbor?Tn | less'
alias vboxmanage=VBoxManage

# OSX
if [ -d /Applications/Meld.app ]; then
  alias meld='open -a Meld --args'
  alias chrome='open -a "Google Chrome" --args'
  alias google-chrome='/Applications/Google\ Chrome.app/Contents/MacOS/Google\ Chrome'
fi

### Editor ####################################################################
export EDITOR=emacs
alias e=$EDITOR
function emacs {
  # Make emacs start in the background, change window title
  if [ "$1" == "-nw" ]; then
    command emacs "$@"
    return
  elif [ `uname` = "Darwin" ]; then
    /Applications/Emacs.app/Contents/MacOS/Emacs "$@" &
  elif [ "$DISPLAY" ] || [ "$OS" = "Windows_NT" ]; then
    command nohup emacs "$@" &
  else
    # for console
    command emacs "$@"
  fi
}


### Pager #####################################################################
alias less="less --shift 5 --ignore-case --chop-long-lines --RAW-CONTROL-CHARS --LONG-PROMPT"
export PAGER=less
export LESSOPEN="| lesspipe.sh %s"


### GPG, SSH and paswords  ###################################################
# Start gpg-agent and connect SSH agent only if secret keys are available
if gpg --list-secret-keys awdeorio &> /dev/null; then
  export GPG_TTY=$(tty)
  gpgconf --launch gpg-agent
  export SSH_AUTH_SOCK=$(gpgconf --list-dirs agent-ssh-socket)
fi

# Configure Password Store
# https://www.passwordstore.org/
# http://www.tricksofthetrades.net/2015/07/04/notes-pass-unix-password-manager/
export PASSWORD_STORE_DIR=${HOME}/Dropbox/password-store
export PASSWORD_STORE_CLIP_TIME=45


### Path stuff ################################################################
# remove item from $PATH
path-remove () {
  local IFS=':'
  local NEWPATH
  for DIR in $PATH; do
    if [ "$DIR" != "$1" ]; then
      NEWPATH=${NEWPATH:+$NEWPATH:}$DIR
    fi
  done
  export PATH=${NEWPATH};
}

# add item to end of $PATH, uniquely
path-append () {
  [ -d $1 ] || return 1    # make sure directory exists
  path-remove $1           # remove the directory
  export PATH=${PATH}:${1} # append the directory
}

# add item to beginning of $PATH, uniquely
path-prepend () {
  [ -d $1 ] || return 1     # make sure directory exists    
  path-remove $1            # remove the directory
  export PATH=${1}:${PATH}  # append the directory
}

path-append /usr/local/bin
path-append /usr/local/sbin
path-append /usr/bin
path-append /usr/sbin
path-append /bin
path-append /sbin
path-prepend ${HOME}/bin
path-append ${HOME}/local/bin
path-append ${HOME}/local/sbin
path-append ${HOME}/.rvm/bin   # Add RVM to PATH for scripting
if [ `whoami` != "root" ]; then
  path-append /usr/caen/bin
  path-append /usr/um/bin
fi


### local tool installs ########################################################
[ -d ${HOME}/local/lib ]     && export LIBARY_PATH=${LIBRARY_PATH}:${HOME}/local/lib
[ -d ${HOME}/local/lib ]     && export LD_LIBRARY_PATH=${LD_LIBRARY_PATH}:${HOME}/local/lib
[ -d ${HOME}/local/lib ]     && export LD_RUN_PATH=${LD_RUN_PATH}:${HOME}/local/lib
[ -d ${HOME}/local/include ] && export CPATH=${CPATH}:${HOME}/local/include
[ -d ${CPATH} ]              && export C_INCLUDE_PATH=${C_INCLUDE_PATH}:${CPATH}
[ -d ${CPATH} ]              && export CPLUS_INCLUDE_PATH=${CPLUS_INCLUDE_PATH}:${CPATH}
[ -d ${HOME}/local/man ]     && export MANPATH=${HOME}/local/man:${MANPATH}

# OS X GNU Coreutils
path-prepend /usr/local/opt/coreutils/libexec/gnubin
[ -d /usr/local/opt/coreutils/libexec/gnuman ] && export MATHPATH=/usr/local/opt/coreutils/libexec/gnuman:$MANPATH

# local perl module installs
if [ -d ${HOME}/local/lib/perl5 ]; then
  PERL5LIB=${PERL5LIB}:${HOME}/local/lib64/perl5/site_perl/5.8.8/x86_64-linux-thread-multi
  PERL5LIB=${PERL5LIB}:${HOME}/local/lib/perl5/site_perl/5.8.8
  PERL5LIB=${PERL5LIB}:${HOME}/local/lib/perl5/site_perl
  PERL5LIB=${PERL5LIB}:${HOME}/local/lib64/perl5/vendor_perl/5.8.8/x86_64-linux-thread-multi
  PERL5LIB=${PERL5LIB}:${HOME}/local/lib/perl5/vendor_perl/5.8.8
  PERL5LIB=${PERL5LIB}:${HOME}/local/lib/perl5/vendor_perl
  PERL5LIB=${PERL5LIB}:${HOME}/local/lib64/perl5/5.8.8/x86_64-linux-thread-multi
  PERL5LIB=${PERL5LIB}:${HOME}/local/lib/perl5/5.8.8
  export PERL5LIB;
fi

# local python module installs
if [ -d ${HOME}/local/lib/python2.6 ]; then
  export PYTHONPATH=${HOME}/local/lib/python2.6:${PYTHONPATH}
  export PYTHONUSERBASE=${HOME}/local
fi
export PYTHONSTARTUP=~/.pythonrc.py
path-prepend /usr/local/opt/sqlite/bin

# local Ruby
[[ -s "$HOME/.rvm/scripts/rvm" ]] && source "$HOME/.rvm/scripts/rvm"

# CCache
path-prepend /usr/lib/ccache/bin || path-prepend /usr/lib/ccache


################################################################################
# Test for an interactive shell.  There is no need to set anything past this 
# point for scp and rcp, and it's important to refrain from outputting 
# anything in those cases.
[[ $- != *i* ]] && return


### Utility Functions #########################################################

# recursively grep for string
alias gg='grep -r . --binary-files=without-match --exclude-dir ".git" --exclude "*~" -e'

# Find a file with a pattern in name:
function ff() { 
    find . -type f -iwholename '*'$*'*' ;
}

# Find a file with pattern $1 in name and Execute $2 on it:
function fe() {
  find . -type f -iname '*'$1'*' -exec "${2:-file}" {} \;  ;
}

# Alias for locate on OSX
if [ `uname` = "Darwin" ]; then
  alias locate='mdfind -name'
fi


### Printing ##################################################################
# enscript --margins=left:right:top:bottom in postscript points
# the following gives L=R=T=B=1in
export ENSCRIPT='--media=Letter --word-wrap --margins=72:72:72:72'


### Prompt Look and Feel ######################################################
set -o emacs                         # emacs commandline mode
set -o history                       # enable up-arrow command history
export HISTIGNORE="&:ls:cd:bg:fg:ll" # ignore these commands in history
export HISTCONTROL="ignoredups"      # ignore duplicates in history
export FIGNORE="~"                   # don't show these prefixes in tab-comp
shopt -s checkwinsize                # keep LINES and COLUMNS up to date

function find_git_context() {
  # Based on https://github.com/jimeh/git-aware-prompt

  # Branch
  local BRANCH
  local GIT_BRANCH
  if BRANCH=$(git rev-parse --abbrev-ref HEAD 2> /dev/null); then
    if [[ "$branch" == "HEAD" ]]; then
      BRANCH='detached*'
    fi
    GIT_BRANCH="$BRANCH"
  else
    GIT_BRANCH=""
  fi

  # '*' for dirty
  local STATUS=$(git status --porcelain 2> /dev/null)
  local GIT_DIRTY
  if [[ "$STATUS" != "" ]]; then
    GIT_DIRTY='*'
  else
    GIT_DIRTY=''
  fi

  # Concatenate
  GIT_CONTEXT="${GIT_BRANCH}${GIT_DIRTY}"
}

function ps1_context {  
	# For any of these bits of context that exist, display them and append
	# a space.  Ref: https://gist.github.com/datagrok/2199506
	VIRTUAL_ENV_BASE=`basename "$VIRTUAL_ENV"`
  find_git_context
	for v in "${GIT_CONTEXT}" \
             "${debian_chroot}" \
             "${VIRTUAL_ENV_BASE}" \
             "${GIT_DIRTY}" \
             "${PS1_CONTEXT}"; do
		echo -n "${v:+$v }"
	done
}

# Fancy Prompt
source ~/.bashrc_colors
if [ "$LOGNAME" == "root" ]; then
  # root
  export PS1='\[${bldred}\]\]\u@\h \[${bldblue}\]\W\n\$ \[${txtrst}\]'
elif [ "$SSH_CONNECTION" ]; then
  # remote machines
  export PS1='$(ps1_context)\[${bldcyn}\]\u@\h \[${bldblu}\]\W\n\$ \[${txtrst}\]'
else
  # local machine
  export PS1='\[${txtpur}\]$(ps1_context)\[${bldgrn}\]\u@\h \[${bldblu}\]\W\n\$ \[${txtrst}\]'
fi

# Change the window title of X terminals
case $TERM in
  xterm*|rxvt|Eterm|eterm)
    PROMPT_COMMAND='echo -ne "\033]0;${USER}@${HOSTNAME%%.*}:${PWD/$HOME/~}\007"'
    ;;
  screen)
    PROMPT_COMMAND='echo -ne "\033_${USER}@${HOSTNAME%%.*}:${PWD/$HOME/~}\033\\"'
    ;;
esac

# Colorized output
LS=ls
if which gls &> /dev/null; then
  # GNU ls on OSX
  LS=gls
fi
if `ls --version | grep -q GNU &> /dev/null`; then
  # GNU ls
  eval `dircolors -b ${HOME}/.DIR_COLORS`
  LSOPT="--color=auto --human-readable --quoting-style=literal --ignore-backups --ignore $'Icon\r'"
else
  # BSD ls
  # -G is for color
  LSOPT="-G"
fi
alias ls="${LS} -h ${LSOPT}"
alias ll="${LS} -h -l ${LSOPT}"
alias la="${LS} -h -A ${LSOPT}"


### Homebrew package manager customization ###################################
if which brew &> /dev/null; then
  export HOMEBREW_NO_AUTO_UPDATE=1
fi


### Bash-completion ###########################################################
if which brew &>/dev/null && [[ -f $(brew --prefix)/etc/bash_completion ]]; then
  # OS X
  . $(brew --prefix)/etc/bash_completion
elif [[ $PS1 && -f /usr/share/bash-completion/bash_completion ]]; then
  . /usr/share/bash-completion/bash_completion
fi
for F in `find ${HOME}/.bash_completion.d/ -type f`; do
  source $F
done

### Todotxt setup #############################################################
export TODO_DIR=${HOME}/Dropbox/lists/todo/work
alias t='todo.sh'
alias et='e ${HOME}/Dropbox/scratch.txt ${HOME}/Dropbox/lists/todo/*/todo.txt'

# todo toggle
# switches default todo list
function tt {
  TODO_DIRS=(`ls -d Dropbox/lists/todo/*/`)
  NEW_DIR_IDX=0
  if [ "$TODO_DIR" == "${TODO_DIRS[$NEW_DIR_IDX]}" ]; then
    NEW_DIR_IDX=1;
  fi
  echo "TODO_DIR=${TODO_DIRS[$NEW_DIR_IDX]}"
  export TODO_DIR="${TODO_DIRS[$NEW_DIR_IDX]}";
}


# Clear History at the very end
history -c
