export ZSH="$HOME/.oh-my-zsh"

ZSH_THEME="robbyrussell"

HIST_STAMPS="mm/dd/yyyy"
HISTSIZE=100000
SAVEHIST=100000

plugins=(
  vi-mode
  web-search
)

source $ZSH/oh-my-zsh.sh

export DOCKER_DEFAULT_PLATFORM=linux/amd64
export EDITOR='nvim'
export MANPAGER='nvim +Man!' # open man pages in nvim
export PATH="$PATH:$HOME//go/bin"
export PATH="$PATH:$HOME/Library/Python/3.8/bin"
export PATH="$PATH:/opt/homebrew/bin"
export PATH="$PATH:/usr/local/bin"
export PYTHONDONTWRITEBYTECODE=1

eval "$(rbenv init -)"

[ -f ~/.fzf.zsh ] && source ~/.fzf.zsh
export FZF_DEFAULT_COMMAND='{ rg --files; rg --files --null | xargs -0 dirname | sort -u; }'
export FZF_CTRL_T_COMMAND="$FZF_DEFAULT_COMMAND"

# delete all views except the ones for notes, not just the ones from ~/code
alias clear_views="rm ~/.local/state/nvim/view/*"
alias count_views="ls ~/.local/state/nvim/view/ | wc -l"
alias clone="gclone"
alias decode="base64 -D < <(pbpaste)"
alias diff_vimrc="nvim -d ~/code/scripts/nvim/init.lua ~/.config/nvim/init.lua"
alias diff_lazylock="nvim -d ~/code/scripts/nvim/lazy-lock.json ~/.config/nvim/lazy-lock.json"
alias diff_wezrc="nvim -d ~/code/scripts/.wezterm.lua ~/.wezterm.lua"
alias diff_zshenv="nvim -d ~/code/scripts/.zshenv ~/.zshenv"
alias diff_zshrc="nvim -d ~/code/scripts/.zshrc ~/.zshrc"
alias e="nvim"
alias f="rg --files | rg -i"
alias fd="rg --files --null | xargs -0 dirname | sort -u | rg -i"
alias ff="~/code/njaczko/scripts/focus_files"
alias ff_todos='ff set-absolute $(list_todos)'
alias gad="git add ."
alias gap="git add -p"
alias gc="git commit -m"
alias gcb="git checkout -b"
alias gdmstat='git diff master --stat'
alias gl="git log --oneline"
alias gln="git log | nvim -R"
alias gp="git push"
alias gs="git status"
alias hist="history > /tmp/zsh_history && nvim -R -c 'set ft=zshhistory' /tmp/zsh_history"
alias links="nvim ~/code/scripts/link.html"
alias list_todos='git diff master --name-only --line-prefix=`git rev-parse --show-toplevel`/ -S"TODO"'
alias main="git checkout main"
alias master="git checkout master"
alias n="nvim ~/notes/nick_jaczko.md"
alias open_todos='list_todos | xargs nvim +/TODO'
alias prune_branches="git branch | grep -v \"master\" | grep -v \"main\" | grep -v \"*\" | xargs git branch -D"
alias rgf="~/code/njaczko/scripts/rgf"
alias rgi="rg -i"
alias sz="source ~/.zshrc"
alias t="nvim ~/code/.throwaway"
alias term="nvim -c terminal"
alias s="nvim ~/code/.draft-slack-message -c 'set ft=markdown spell'"
alias update='git pull --rebase'
alias udpate='git pull --rebase'
alias vimrc="nvim ~/.config/nvim/init.lua"
alias wez='cd ~/code/wezterm && cargo run --release --bin wezterm'
alias wezrc="nvim ~/.wezterm.lua"
alias wt="~/code/scripts/time"
alias zshenv="nvim ~/.zshenv"
alias zshrc="nvim ~/.zshrc"
alias txts='dig @8.8.8.8 +short -t txt'
# copy current branch name to clipboard
alias branch='git rev-parse --abbrev-ref HEAD | pbcopy'
# open quick look preview. pass path to a file.
alias ql='qlmanage -p'
alias stash='git stash'
alias gb='git branch --sort=-committerdate'
alias ed="ed -p'>'"
# more wttr info: https://github.com/chubin/wttr.in
alias weather="curl 'wttr.in/Washington?1F'"
alias sunset="curl 'wttr.in/Washington?format=%s'"
alias view="gh pr view -w"

# for jump: https://github.com/gsamokovarov/jump
eval "$(jump shell)"

# fuzzy checkout git branches
fco() {
  git checkout "$(git branch | fzf -f "$1" | head -n1 | xargs)"
}

gclone() {
  git clone $(pbpaste)
  cd  $(ls -1t | head -n1)
}

ghpr() {
  gh pr checkout $1
}

gphead() {
  git push --set-upstream origin $(git rev-parse --abbrev-ref HEAD) && gh pr create -w
}

cg() {
  # rg doesn't really produce YAML output, but it's close enough that this
  # provides some basic syntax highlighting
  rg $@ --vimgrep | nvim -R -c 'set ft=yaml'
}

cgi() {
  # rg doesn't really produce YAML output, but it's close enough that this
  # provides some basic syntax highlighting
  rg -i $@ --vimgrep | nvim -R -c 'set ft=yaml'
}

rgo() {
  rg $@ -l | xargs nvim
}

rgio() {
  rg -i $@ -l | xargs nvim
}

diffself() {
  foo=".foo.$(basename $1)"
  bar=".bar.$(basename $1)"
  cp $1 $foo
  cp $1 $bar
  nvim -d $foo $bar
  rm $foo $bar
}

# $1 must be a relative file path
diffmaster() {
  master=".master.$(basename $1)"
  git show "master:./$1" > $master
  nvim -d $master $1
  rm $master
}

# depends on the oil.nvim plugin. $1 must be a file path.
oil() {
  nvim -c ":Oil $1"
}

# prints the certificate expiration info for a domain.
# example: certExpiration foo.example.com
certExpiration() {
  echo "checking $1"
  sslscan --no-cipher-details --no-ciphersuites --no-compression --no-fallback --no-groups --no-heartbleed --no-renegotiation $1 | rg Not.valid
}

# display the NWS hourly temperature forecast for Washington, DC
dcHeatIndex() {
  curl --silent 'https://forecast.weather.gov/meteograms/Plotter.php?lat=38.9156&lon=-77.0526&wfo=LWX&zcode=DCZ001&gset=18&gdiff=3&unit=0&tinfo=EY5&ahour=0&pcmd=101&lg=en&indu=1!1!1!&dd=&bw=&hrspan=48&pqpfhr=6&psnwhr=6' | imgcat --width 80%
}

# display the NWS hourly forecast for Washington, DC
dcWeather() {
  curl --silent 'https://forecast.weather.gov/meteograms/Plotter.php?lat=38.9198&lon=-77.0371&wfo=LWX&zcode=DCZ001&gset=18&gdiff=3&unit=0&tinfo=EY5&ahour=0&pcmd=10100110100000000000000000000000000000000000000000000000000&lg=en&indu=1!1!1!&dd=&bw=&hrspan=48&pqpfhr=6&psnwhr=6' | imgcat --width 80%
}

# unote opens a md file named with a ULID and writes the current datetime.
# great for jotting down quick notes.
unote() {
  nvim $(ulid).md -c 'r! echo % | sed 's/.md//' | xargs ulid -l'
}
# lastunote opens the most recent ulid note. `grep '^01'` is a little hacky: it could
# match other file names and over time ULIDs will have different prefixes, but
# it's convenient for now.
#
# pass an int arg to specify how many notes to open. defaults to 1 if no args are provided.
lastunote() {
  ls -1 | grep '^01' | sort -r | head -n${1:-1}
}

elastunote() {
  lastunote | xargs nvim
}

allunotes() {
  ls -1 | grep '^01' | sort -r
}

gdm() {
  if [[ -z "$1" ]]; then
    git diff master | nvim -R;
  else
    git diff master -- "$1" | nvim -R;
  fi
}

# opens files that have the merge conflict markers
open_merge_conflicts() {
  rg '<<<<<<<' $(rg '>>>>>>>' -l) -l | xargs nvim -c "MergeConflicts"
}

# fuzzy-find files, then preview them
qlf() {
  rg --files | rg -i "$1" | sed 's/ /\\ /g' |  xargs qlmanage -p
}

ef() {
  rg --files | rg -i "$1" | xargs nvim
}
