# ~/.zshrc isn't sourced for all shells, such as neovim's shell. anything that
# should be sourced _everywhere_ needs to be included here (~/.zshenv) instead.
#
autoload -Uz compinit
compinit

export PATH="$PATH:/opt/homebrew/bin"

alias shrug="echo '¯\_(ツ)_/¯' | pbcopy"
alias tree="exa -T"

# uuidgen generates uppsercase uuids. use tr to lowercase it
uuid() {
  uuidgen | tr '[:upper:]' '[:lower:]'
}

# print out the current time in RFC3339 format
now() {
  gdate --rfc-3339=seconds | sed 's/ /T/'
}

# print out the RFC3339 timestamp for 24 hours from now
tomorrow() {
  gdate --date="+1 day" --rfc-3339=seconds | sed 's/ /T/'
}

case "$HOME" in
  '/Users/njaczk') source $HOME/code/nick/bin/ramp.zsh;;
  *) ;;
esac

. "$HOME/.cargo/env"
