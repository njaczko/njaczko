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

case "$HOME" in
  '/Users/njaczk') source $HOME/code/nick/bin/ramp.zsh;;
  *) ;;
esac
