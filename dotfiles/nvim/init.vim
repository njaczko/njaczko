" Nick Jaczko's (www.github.com/njaczko) neovim configuration file.
" nvim expects to find this file at ~/.config/nvim/init.vim

" manage plugins with vim-plug
call plug#begin('~/.local/share/nvim/plugged')
Plug 'morhetz/gruvbox' " color scheme
Plug 'google/vim-jsonnet', { 'for': 'jsonnet' } " jsonnet syntax highlighting
Plug 'leafgarland/typescript-vim' " typescript syntax highlighting
Plug 'njaczko/vim-reslang' " reslang syntax highlighting
Plug 'ap/vim-buftabline'
Plug 'dense-analysis/ale' " async linting engine
Plug 'easymotion/vim-easymotion', { 'on': ['<Plug>(easymotion-bd-f)', '<Plug>(easymotion-sn)'] } " easymotion
Plug 'https://tpope.io/vim/repeat.git' " repeat commands
Plug 'https://tpope.io/vim/surround.git' " smart braces, parens, quotes, etc.
Plug 'jiangmiao/auto-pairs' " smart braces, parens, brackets
Plug 'junegunn/fzf'
Plug 'junegunn/fzf.vim'
Plug 'neoclide/coc.nvim', {'branch': 'release'} " autocompletion
Plug 'tpope/vim-commentary' " block commenting
Plug 'xolox/vim-misc', { 'for': 'notes'} " note taking dependency
Plug 'xolox/vim-notes', { 'for': 'notes'} " note taking
Plug 'lifepillar/pgsql.vim', { 'for': 'sql'} " postgres syntax highlighting
call plug#end()


" TABS, SPACES, AND FILETYPES ##################################################

"haml hamljs javascript jsonnet lua python ruby sh vim yaml yml zsh tf
autocmd Filetype * setlocal tabstop=2 expandtab shiftwidth=2 smarttab
autocmd Filetype notes,rst setlocal tabstop=3 shiftwidth=3 expandtab
autocmd Filetype c,go,typescript setlocal tabstop=4 expandtab shiftwidth=4 smarttab
" tabs instead of spaces in makefiles.
autocmd FileType make set noexpandtab

" textwidth is most useful in markdown files
autocmd FileType markdown set textwidth=80

" filetypes
autocmd BufNewFile,BufRead *.tsx set ft=typescript
autocmd BufNewFile,BufRead *.pegjs set ft=pegjs


" MAPPINGS #####################################################################

map <c-j> 10j
map <c-k> 10k
" yank to clipboard
map Y "+y
nnoremap <c-w> <c-w><c-w>
nnoremap Z :w<CR>
nmap I eli
nmap W 5w
nmap B 5b
vmap W 5w
vmap B 5b
map a ^i
imap jj <Esc>
imap jk <Esc>
imap kk <Down><CR>
"comment out the line with the cursor
nmap <Leader>c Vgc
nmap <Leader>z z=1<CR>
" skip the bullet point when editing beginning of line in notes
autocmd Filetype notes nmap a ^wi
" textwidth wrap all the lines in the file
nmap gQ gggqG
" wrap a long line without having to enter visual mode
nmap gq Vgq
"retain selection after `>` and `<`
vmap > >gv
vmap < <gv
" remap normal mode arrow keys to scroll through quickfix locations
nnoremap <Up> :lprev<CR>
nnoremap <Down> :lnext<CR>
" base64 encode/decode selected text
vnoremap <leader>e c<c-r>=substitute(system('base64', @"), '\n', '', '')<cr><esc>
vnoremap <leader>d c<c-r>=system('base64 --decode', @")<cr><esc>
" key mappings will not time out waiting for additional chars
set notimeout
" sub all instances of the word under the cursor with \s
nnoremap <Leader>s :%s/\<<C-r><C-w>\>//g<Left><Left>
" same as above, except pre-fill new word with old word
nnoremap <Leader>S :%s/\<<C-r><C-w>\>/<C-r><C-w>/g<Left><Left>
" :q quits all in diff mode
if &diff | nnoremap :q<CR> :qa<CR> | endif
" search for the visually selected text
vnoremap <Leader>f y/\V<C-R>=escape(@",'/\')<CR><CR>
" noh
nmap <silent> <Leader>n :noh<CR>


" COMMANDS #####################################################################

command Yaml set ft=yaml
command Adoc set ft=asciidoc
command Json set ft=json
" turn on spell checking (use [s and ]s to move between misspelled words)
command Spell set spell
" turn off spell checking
command Nospell set spell &
command StripWhitespace %s/\s\+$//e
command Wrap set wrap
command Nowrap set nowrap
command Norel set norelativenumber
command Rel set relativenumber
command -nargs=* GlobalReplace call GlobalReplace(<f-args>)
command InsertPrintDebugger execute "r ~/.config/nvim/debugger-print-statements/" . &ft

" prettify the selected json lines
command -range PrettyJson <line1>,<line2>!python -m json.tool
" prettify xml
command! PrettyXML :%!python3 -c "import xml.dom.minidom, sys; print(xml.dom.minidom.parse(sys.stdin).toprettyxml())"
nnoremap = :PrettyXML<Cr>

" highlight column 80. off by default because of screen burn in.
command CharBar highlight colorcolumn ctermbg=DarkGray | set colorcolumn=80
command NoCharBar set colorcolumn=

" do not redraw for commands that were not typed (e.g. mapping that enters
" visual mode and highlights)
set lazyredraw

" open an empty 40 column buffer to roughly center the current buffer on wide
" displays
command Center 40vsplit empty

" loading plugins with vim-plug is somewhat time expensive during nvim
" startup. these plugins are rarely used, but sometimes useful, so we load
" them only on demand
function LoadMiscPlugins()
  call plug#begin('~/.local/share/nvim/plugged')
  Plug 'alunny/pegjs-vim'
  Plug 'joshdick/onedark.vim', { 'on': 'Onedark' } " color scheme
  Plug 'scrooloose/nerdtree', { 'on': 'NERDTreeToggle' } " file tree explorer
  Plug 'tpope/vim-fugitive', { 'on': 'Git' } " git
  Plug 'tsandall/vim-rego'
  Plug 'evanleck/vim-svelte', {'branch': 'main'} " svelte syntax highlighting
  call plug#end()
endfunction
command LoadMiscPlugins call LoadMiscPlugins()

" persist folds between sessions
" views saved in ~/.local/share/nvim/view
" makes a view for every file that is opened
autocmd BufWinLeave * silent! mkview
autocmd BufWinEnter * silent! loadview

" strip whitespace on quit
autocmd BufWritePre * silent! %s/\s\+$//e

" close location list when closing main file
autocmd BufWinEnter quickfix nnoremap <silent> <buffer> q :cclose<cr>:lclose<cr>
autocmd BufEnter * if (winnr('$') == 1 && &buftype ==# 'quickfix' ) | bd | q | endif


" HIGHLIGHTS ###################################################################

function ColorSchemeOverrides()
  highlight clear SignColumn " no background for line numbers
  " dark gray highlight for folded lines
  highlight Folded guibg=#404040
  highlight clear LineNr
  highlight clear CursorLineNr

  " auto highlight keywords. needs to be called after colorscheme stuff
  hi YellowBG ctermbg=3 guibg=hotpink guifg=black ctermfg=black
  " incomplete n char easymotion search
  hi EasyMotionIncSearch ctermbg=none ctermfg=red
  call matchadd('YellowBG', '<Paste>')
  call matchadd('YellowBG', 'TODO')
endfunction

" this needs to be called before colorscheme. override colorscheme and use
" black background
au ColorScheme * hi Normal ctermbg=None
colorscheme gruvbox
call ColorSchemeOverrides()

" highlight dates in output from bash history command
autocmd Filetype history call HighlightHistory()
function HighlightHistory()
  syn match even_date '^.*/.*[02468]/.*[[:space:]][[:space:]]'
  syn match odd_date '^.*/.*[13579]/.*[[:space:]][[:space:]]'
  hi def link odd_date Constant
  hi def link even_date String
endfunction


" PLUGIN CONFIGURATION #########################################################

" vim-plug will only load the easymotion plugin when one of these commands is
" run. if you want to use other easymotion commands you'll have to add them to
" the list or load the plugin all the time (~7-10ms).
" easymotion search for 1 char
nmap m <Plug>(easymotion-bd-f)

" fzf
nmap <silent> M :BLines<cr>
nmap <silent> <c-p> :Files<CR>
" highlight matched text in red instead of dark green
let g:fzf_colors = { 'hl': ['fg', 'Statement'], 'hl+': ['fg', 'Statement'] }

" buffers as tabs
set hidden
" vim-buftabline: only show when >1 buffers open
let g:buftabline_show=1
" use arrow keys to switch buffers
nmap <silent> <Left> :bprev!<CR>
nmap <silent> <Right> :bnext!<CR>
" close current buffer. in the future, could use some func that will exit vim
" when the last buffer is deleted
nmap <silent> <Leader>q :bd<CR>

" jiangmiao/auto-pairs: don't do auto pairs for single and double quotes
let g:AutoPairs = {'(':')', '[':']', '{':'}', '```':'```', '"""':'"""', "'''":"'''", "`":"`"}

" directory-wide replace all instances of 'old' with 'new'
function GlobalReplace(old, new)
  execute "args `rg" a:old "-l` | argdo %s/" . a:old . "/" . a:new . "/g | up"
endfunction

" vim-notes
let g:notes_directories = ['~/notes']
autocmd BufNewFile,BufRead *.note,*.notes set ft=notes
autocmd BufRead,BufNewFile ~/notes/* set ft=notes
autocmd Filetype notes set foldmethod=manual
autocmd BufWritePost ~/notes/* call FixAllNoteLevels()
command FixNotes call FixAllNoteLevels()
" make sure each level of indentation uses the correct bullet char
function FixAllNoteLevels()
  " set a mark so we can return to this location when we're done fixing
  mark x
  silent call FixNoteLevel(0, "•")
  silent call FixNoteLevel(1, "◦")
  silent call FixNoteLevel(2, "▸")
  silent call FixNoteLevel(3, "▹")
  silent call FixNoteLevel(4, "▪")
  silent call FixNoteLevel(5, "▫")
  normal 'x
endfunction

function FixNoteLevel(level, char)
  execute '%s/\(^ ' . repeat("   ", a:level) . '\)\(•\|◦\|▸\|▹\|▪\|▫\)/' repeat("   ", a:level) . a:char . "/ge"
endfunction

" ALE
" only lint on save
let g:ale_lint_on_text_changed = 'never'
let g:ale_fix_on_save = 1
" fixing legacy code sometimes results in huge diffs. don't automatically fix
" often-legacy filetypes
autocmd Filetype ruby,typescript let g:ale_fix_on_save = 0
" all of the linters need to be installed in order to work. ALE will not warn
" if they are enabled but not installed. Some of the Go linters come with the
" Go installation (e.g. gofmt) but others need to be installed separately.
let g:ale_linters = {
\   'go': ['gopls', 'golint', 'gofmt', 'govet', 'goimports'],
\}
let g:ale_fixers = {
\   '*': ['trim_whitespace'],
\   'go': ['gofmt', 'goimports'],
\   'javascript': ['prettier'],
\   'html': ['prettier'],
\   'yaml': ['prettier'],
\   'markdown': ['prettier'],
\   'ruby': ['rubocop'],
\}
" can renable these as needed
" \   'typescript': ['prettier'], " large diffs with legacy code
autocmd Filetype go,typescript nmap gd :ALEGoToDefinition<CR>

" COC
" rename symbol using LSP
nmap <leader>r <Plug>(coc-rename)

" pgsql.vim. treat all sql files as postgres.
let g:sql_type_default = 'pgsql'

" xolox/vim-notes
" don't highlight the names of other notes (they are still hyperlinks)
hi notesName ctermfg=fg
" bold is hard to distinguish from normal text. let's make it a different color
hi notesBold ctermfg=DarkRed


" SETTINGS AND MISCELLANEOUS ###################################################

set mouse=a
" only search in open folds
set fdo-=search

" matching parens hurts performance
let g:loaded_matchparen=1

"hybrid relative line numbers
set number relativenumber
augroup numbertoggle
  autocmd!
  autocmd BufEnter,FocusGained,InsertLeave * set relativenumber
  autocmd BufLeave,FocusLost,InsertEnter   * set norelativenumber
augroup END

" shada file grows very large and takes forever to load remove this line if we
" miss persistent registers/marks/etc., search and command history.
" see :help 'shada
" set shada="/10,:10,@10"
set shada="NONE"

" abbreviations
ab teh the

" handling case in search
set ignorecase
set smartcase

" show file name in status line
set laststatus=2
set statusline=%f

" Use persistent history to allow undo after file close
if !isdirectory("/tmp/.vim-undo-dir")
    call mkdir("/tmp/.vim-undo-dir", "", 0700)
endif
set undofile undodir=/tmp/.vim-undo-dir
" disable undofiles for some files that might contain secrets
autocmd BufEnter *.credentials.json set noundofile
autocmd BufEnter /private* set noundofile
autocmd BufEnter /tmp* set noundofile
autocmd BufEnter *.private set noundofile
