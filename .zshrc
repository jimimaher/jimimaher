export REFRESH_CREDS_BETA=true
alias killvpn="sudo kill $(ps auxwww | grep "[a]cvc-openvpn" | awk '{print $2}')"

# function to git add, commit, and push with a message as input
function gacp() {
  git add .
  git commit -m "$1"
  git push
}

alias gpo='git pull origin $(git branch --show-current)'

function git-fcc() {
  git add -A
  git commit --fixup HEAD
  GIT_SEQUENCE_EDITOR=: git rebase -i --autosquash HEAD~2
}

function git-fcc-f() {
  git add -A
  git commit --fixup HEAD
  GIT_SEQUENCE_EDITOR=: git rebase -i --autosquash HEAD~2
  git push -f
}

function git-acp() {
  git add .
  git commit -m "$1"
  git push
}
function git-acp-f() {
  git add .
  git commit -m "$1"
  git push -f
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

function grm() {
  local current_branch=$(git rev-parse --abbrev-ref HEAD)
  echo current_branch: $current_branch
  echo "checkout master"
  git checkout master
  echo "pulling from master"
  git pull
  echo "checkout checkout $current_branch"
  git checkout $current_branch
  echo "rebase master"
  git rebase master
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

function gcbjm() {
  # if no $1, exit
  if [ -z "$1" ]; then
    echo "Please provide a branch name"
    return
  fi
  git checkout -b jm/$1
}
 
export PATH=$HOME/bin:/usr/local/bin:$PATH

export ZSH="$HOME/.oh-my-zsh"

ZSH_THEME="robbyrussell"

# Which plugins would you like to load?
# Standard plugins can be found in $ZSH/plugins/
# Custom plugins may be added to $ZSH_CUSTOM/plugins/
# Example format: plugins=(rails git textmate ruby lighthouse)
# Add wisely, as too many plugins slow down shell startup.
plugins=(git)

source $ZSH/oh-my-zsh.sh

export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"  # This loads nvm
[ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"  # This loads nvm bash_completion

# pnpm
export PNPM_HOME="/Users/james.maher/Library/pnpm"
export PATH="$PNPM_HOME:$PATH"
export PATH=$PATH:./node_modules/.bin
export PATH="$PATH:/Applications/Visual Studio Code.app/Contents/Resources/app/bin"

# pnpm endeval "$(/opt/homebrew/bin/brew shellenv)"

eval "$(pyenv init --path)"

echo "alias python=/usr/bin/python3"

code () { VSCODE_CWD="$PWD" open -n -b "com.microsoft.VSCode" --args $* ;}

source ~/.bash_profile
source ~/.zsh_profile

alias grm="git rebase master"

# bun completions
[ -s "/Users/james.maher/.bun/_bun" ] && source "/Users/james.maher/.bun/_bun"

# bun
export BUN_INSTALL="$HOME/.bun"
export PATH="$BUN_INSTALL/bin:$PATH"

