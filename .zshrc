function docker-login() {
  unset AWS_SESSION_TOKEN AWS_ACCESS_KEY_ID AWS_SECRET_ACCESS_KEY AWS_PROFILE
  AWS_PROFILE=okta-prod-engineer aws --region us-west-2 ecr get-login-password | docker login --username AWS --password-stdin 611706558220.dkr.ecr.us-west-2.amazonaws.com
  echo "Logged in to prod"
  AWS_PROFILE=okta-build-readonly aws --region us-west-2 ecr get-login-password | docker login --username AWS --password-stdin 839591177169.dkr.ecr.us-west-2.amazonaws.com
  echo "Logged in to build"
}

function cde(){
  code ../$1
  cd ../$1
}

# function to git add, commit, and push with a message as input
function gacp() {
  git add .
  git commit -m "$1"
  git push
}

function gpo(){
  current=$(git branch --show-current)
  git pull origin $current
}

function gcpm() {
  git checkout master
  git pull origin master
}

function git-fresh-branch() {
  git checkout master
  gpo
  git checkout -b $1
}

function grah() {
  echo "git reset all hard"
  git clean -fd
  git reset
  git checkout .
}

function commitWithChangelog() {
  if [[ -z "$1" ]]; then
    echo "Please provide a commit message"
    return
  fi
  if [[ -z "$2" ]]; then
    echo "Optionally provide a bump type (major, minor, patch)"
    return
  fi
  git add .
  git commit -m "$1"
  type=${2:-patch}
  rush change --bulk --bump-type $type --message $1 --bulk
  git-fcc ## optional rebase
}

function git-fcc() {
  git add -A
  git commit --fixup HEAD
  GIT_SEQUENCE_EDITOR=: git rebase -i --autosquash HEAD~2
}

function gfcb() {
  git fetch origin $1
  git checkout -b $1 origin/$1
}

function git-fcc-f() {
  git-fcc
  git push -f
}

function rebase_origin_master() {
  rebase-origin-master
}
function rebase-origin-master() {
  main_branch=master
  if [[ -n "$1" ]]; then
    main_branch=$1
  fi
  git checkout $main_branch
  git pull origin $main_branch
  git checkout -
  git rebase $main_branch
}

function grmf() {
  grm
  git push -f
}

function git-acp() {
  if [[ -z "$1" ]]; then
    echo "Provide a commit message"
    return
  fi

  if [[ -f ".gradlew" ]]; then
    ./gradlew detekt --auto-correct
  fi
 
  set -x
  git add .
  if [[ -n "$3" ]]; then
    git commit -m "$1" "$2"
    git push "$2" "$3"
  elif [[ -n "$2" ]]; then
    git commit -m "$1" "$2"
    git push "$2"
  else
    git commit -m "$1"
    git push
  fi
  set -x
}

function git-acp-f() {
  git add .
  git commit -m "$1"
  git push -f
}

function rugc() {
  rushupdate-gitadd-continuerebase
}
function rushupdate-gitadd-continuerebase() {
  rush update
  git add .
  git rebase --continue
}

function grmru() {
  update_from_master
  rush update
  git add .
  git rebase --continue
}

function gpm() {
  git checkout master
  git pull origin master
}


function gnb() {
  if [[ $1 != jm/* ]]; then
    echo "Converting branch '$1' to 'jm/$1'"
    command git checkout -b "jm/$1"
    return
  fi
}

function git-new-branch() {
  gnb
}

function git-checkout-new-branch() {
  # if no $1, exit
  if [ -z "$1" ]; then
    echo "Please provide a branch name"
    return
  fi
  if [[ $1 != jm/* ]]; then
    echo "Branch name must start with jm/"
    git checkout -b jm/$1
    git branch -D $1
    return
  fi

}

function printTshCluster () {
  tsh status | grep "Kubernetes cluster"
}

function kubeExecSpecificPod() {
  namespace=$1
  pod=$2
  echo Running "kubectl exec -it $pod bash -n $namespace"
  kubectl exec -it -n $namespace $pod -- bash
}

function kubeExecPod() {
  printTshCluster
  namespace=$1
  app=$2
  pod=$(kubectl get pods -n $namespace --selector app=$app --no-headers | awk 'NR==1{print $1}')
  if [[ "$pod" ]]; then
    echo pod found: $pod
    kubeExecSpecificPod $namespace $pod
  else
    echo "No pods found matching $namespace - $app"
  fi
}

function kubeExecMatcher() {
  printTshCluster
  namespace=$1
  search=$2
  # search to lowercase
  search=$(echo $search | tr '[:upper:]' '[:lower:]')
  pod=$(kubectl get pods -n $namespace --no-headers | grep $search | awk 'NR==1{print $1}')

  if [[ -z "$pod" && $namespace != *"-sandbox" ]]; then
    echo "Trying again in sandbox namespace: $namespace-sandbox"
    namespace="$namespace-sandbox"
    pod=$(kubectl get pods -n $namespace --no-headers | grep $search | awk 'NR==1{print $1}')
  fi

  if [[ "$pod" ]]; then
    echo pod found: $pod
    kubeExecSpecificPod $namespace $pod
  else
    echo "No pods found :("
  fi
}

function prodPortForwardExecMatcher() {
  tsh kube login main-00.build-prod-us-west-2
  namespace=$1
  search=$2
  pod=$(kubectl get pods -n $namespace --no-headers | grep $search | awk 'NR==1{print $1}')
  kubectl port-forward -n $namespace $pod 50051:50051
}

function stagingPortForwardExecMatcher() {
  tsh kube login main-00.build-staging-us-west-2
  namespace=$1
  search=$2
  pod=$(kubectl get pods -n $namespace --no-headers | grep $search | awk 'NR==1{print $1}')
  kubectl port-forward -n $namespace $pod 50051:50051
}

# If you come from bash you might have to change your $PATH.
export PATH=$HOME/bin:/usr/local/bin:$PATH

# Path to your oh-my-zsh installation.
export ZSH="$HOME/.oh-my-zsh"

# Set name of the theme to load --- if set to "random", it will
# load a random theme each time oh-my-zsh is loaded, in which case,
# to know which specific one was loaded, run: echo $RANDOM_THEME
# See https://github.com/ohmyzsh/ohmyzsh/wiki/Themes
# ZSH_THEME="evan"
ZSH_THEME="robbyrussell"
# ZSH_THEME="daveverwer"
# ZSH_THEME="garyblessington"
# ZSH_THEME="flazz"

# Set list of themes to pick from when loading at random
# Setting this variable when ZSH_THEME=random will cause zsh to load
# a theme from this variable instead of looking in $ZSH/themes/
# If set to an empty array, this variable will have no effect.
# ZSH_THEME_RANDOM_CANDIDATES=( "robbyrussell" "agnoster" )

# Uncomment the following line to use case-sensitive completion.
# CASE_SENSITIVE="true"

# Uncomment the following line to use hyphen-insensitive completion.
# Case-sensitive completion must be off. _ and - will be interchangeable.
# HYPHEN_INSENSITIVE="true"c

# Uncomment one of the following lines to change the auto-update behavior
# zstyle ':omz:update' mode disabled  # disable automatic updates
# zstyle ':omz:update' mode auto      # update automatically without asking
# zstyle ':omz:update' mode reminder  # just remind me to update when it's time

# Uncomment the following line to change how often to awaorihoaetuto-update (in days).
# zstyle ':omz:update' frequency 13

# Uncomment the following line if pasting URLs and other text is messed up.
# DISABLE_MAGIC_FUNCTIONS="true"

# Uncomment the following line to disable colors in ls.
# DISABLE_LS_COLORS="true"

# Uncomment the following line to disable auto-setting terminal title.
# DISABLE_AUTO_TITLE="true"

# Uncomment the following line to enable command auto-correction.
# ENABLE_CORRECTION="true"

# Uncomment the following line to display red dots whilst waiting for completion.
# You can also set it to another string to have that shown instead of the default red dots.
# e.g. COMPLETION_WAITING_DOTS="%F{yellow}waiting...%f"
# Caution: this setting can cause issues with multiline prompts in zsh < 5.7.1 (see #5765)
# COMPLETION_WAITING_DOTS="true"

# Uncomment the following line if you want to disable marking untracked files
# under VCS as dirty. This makes repository status check for large repositories
# much, much faster.
# DISABLE_UNTRACKED_FILES_DIRTY="true"

# Uncomment the following line if you want to change the command execution time
# stamp shown in the history command output.
# You can set one of the optional three formats:
# "mm/dd/yyyy"|"dd.mm.yyyy"|"yyyy-mm-dd"
# or set a custom format using the strftime function format specifications,
# see 'man strftime' for details.
# HIST_STAMPS="mm/dd/yyyy"

# Would you like to use another custom folder than $ZSH/custom?
# ZSH_CUSTOM=/path/to/new-custom-folder

# Which plugins would you like to load?
# Standard plugins can be found in $ZSH/plugins/
# Custom plugins may be added to $ZSH_CUSTOM/plugins/
# Example format: plugins=(rails git textmate ruby lighthouse)
# Add wisely, as too many plugins slow down shell startup.
plugins=(git)
# export GIT_PROMPT_DISABLE=1

source $ZSH/oh-my-zsh.sh

# User configuration

# export MANPATH="/usr/local/man:$MANPATH"

# You may need to manually set your language environment
# export LANG=en_US.UTF-8

# Preferred editor for local and remote sessions
# if [[ -n $SSH_CONNECTION ]]; then
#   export EDITOR='vim'
# else
#   export EDITOR='mvim'
# fi

# Compilation flags
# export ARCHFLAGS="-arch x86_64"

# Set personal aliases, overriding those provided by oh-my-zsh libs,
# plugins, and themes. Aliases can be placed here, though oh-my-zsh
# users are encouraged to define aliases within the ZSH_CUSTOM folder.
# For a full list of active aliases, run `alias`.
#
# Example aliases
# alias zshconfig="mate ~/.zshrc"
# alias ohmyzsh="mate ~/.oh-my-zsh"

export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"  # This loads nvm
[ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"  # This loads nvm bash_completion

export NVM_DIR="$([ -z "${XDG_CONFIG_HOME-}" ] && printf %s "${HOME}/.nvm" || printf %s "${XDG_CONFIG_HOME}/nvm")"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh" # This loads nvm

# pnpm
export PNPM_HOME="/Users/james.maher/Library/pnpm"
case ":$PATH:" in
  *":$PNPM_HOME:"*) ;;
  *) export PATH="$PNPM_HOME:$PATH" ;;
esac
# pnpm endeval "$(/opt/homebrew/bin/brew shellenv)"

# echo "alias python=/usr/bin/python3"

code () {
  open -a "/Applications/Cursor.app" "$@"
}

# source ~/.bash_profile
# source ~/.zprofile

# bun completions
[ -s "/Users/james.maher/.bun/_bun" ] && source "/Users/james.maher/.bun/_bun"

# bun
export BUN_INSTALL="$HOME/.bun"
export PATH="$BUN_INSTALL/bin:$PATH"


# eval "$(/opt/homebrew/bin/brew shellenv)"

export PATH="$NVM_DIR/versions/node/v20.12.2/bin:$PATH"

# echo "done!"
# Created by `pipx` on 2024-10-31 14:45:55
export PATH="$PATH:/Users/james.maher/.local/bin"
# export PATH="$HOME/.jenv/bin:$PATH"
# eval "$(jenv init -)"


export PYENV_ROOT="$HOME/.pyenv"
command -v pyenv >/dev/null || export PATH="$PYENV_ROOT/bin:$PATH"
eval "$(pyenv init -)"
