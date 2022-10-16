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
Plug 'njaczko/auto-pairs' " smart braces, parens, brackets
Plug 'junegunn/fzf'
Plug 'junegunn/fzf.vim'
Plug 'neoclide/coc.nvim', {'branch': 'release'} " autocompletion
Plug 'tpope/vim-commentary' " block commenting
Plug 'njaczko/vim-notes' " note taking
Plug 'lifepillar/pgsql.vim', { 'for': 'sql' } " postgres syntax highlighting
Plug 'ralismark/opsort.vim' " sort lines based on visual selection
Plug 'nvim-treesitter/nvim-treesitter' " LSP syntax highlighting, etc.
Plug 'njaczko/nvim-dummy-text'
call plug#end()


" TABS, SPACES, AND FILETYPES ##################################################

"haml hamljs javascript jsonnet lua ruby sh vim yaml yml zsh tf
autocmd Filetype * setlocal tabstop=2 expandtab shiftwidth=2 smarttab
autocmd Filetype notes,rst setlocal tabstop=3 shiftwidth=3 expandtab
autocmd Filetype c,go,python,typescript setlocal tabstop=4 expandtab shiftwidth=4 smarttab
" tabs instead of spaces in makefiles.
autocmd FileType make set noexpandtab

" textwidth is most useful in markdown files
autocmd FileType markdown set textwidth=80

" filetypes
autocmd BufNewFile,BufRead *.tsx set ft=typescript
autocmd BufNewFile,BufRead *.pegjs set ft=pegjs
autocmd BufNewFile,BufRead *.tf set ft=hcl
autocmd BufNewFile,BufRead *.hcl set ft=hcl


" MAPPINGS #####################################################################

map <c-j> 10j
map <c-k> 10k
" yank to clipboard
map Y "+y
nnoremap <c-w> <c-w><c-w>
nnoremap K :w<CR>
nnoremap Z :q<CR>
nmap I eli
nmap W 5w
nmap B 5b
vmap W 5w
vmap B 5b
map a ^i
imap jj <Esc>
" comment out the line with the cursor
nmap <Leader>c Vgc
" change a word to the first spelling suggestion
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
" search for the visually selected text
vnoremap <Leader>f y/\V<C-R>=escape(@",'/\')<CR><CR>
" remove highlighting for search matches
nmap <silent> <Leader>n :noh<CR>
" set 'a' mark
nmap <leader>a :mark a<CR>


" COMMANDS #####################################################################

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
command Source source $MYVIMRC

" prettify the selected json lines. requires https://github.com/stedolan/jq
command -range PrettyJson <line1>,<line2>!jq
" prettify xml
command! PrettyXML :%!python3 -c "import xml.dom.minidom, sys; print(xml.dom.minidom.parse(sys.stdin).toprettyxml())"
nnoremap = :PrettyXML<Cr>

" highlight column 80. off by default because of screen burn in.
command Charbar highlight colorcolumn ctermbg=DarkGray | set colorcolumn=80
command Nocharbar set colorcolumn=

" do not redraw for commands that were not typed (e.g. mapping that enters
" visual mode and highlights)
set lazyredraw

" open an empty 40 column buffer to roughly center the current buffer on wide
" displays
command Center 40vsplit empty

" loading plugins with vim-plug is somewhat time expensive during nvim
" startup. these plugins are rarely used, but sometimes useful, so we load
" them only on demand. If the plugins do not work after being loaded, they
" likely need to be installed.
function LoadMiscPlugins()
  call plug#begin('~/.local/share/nvim/plugged')
  Plug 'alunny/pegjs-vim'
  Plug 'joshdick/onedark.vim', { 'on': 'Onedark' } " color scheme
  Plug 'scrooloose/nerdtree', { 'on': 'NERDTreeToggle' } " file tree explorer
  Plug 'tsandall/vim-rego'
  Plug 'tpope/vim-fugitive', { 'on': 'Git' } " git
  Plug 'evanleck/vim-svelte', {'branch': 'main'} " svelte syntax highlighting
  Plug 'mbbill/undotree'
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

" openGithub crafts the GitHub url for the current line and opens it in the
" browser
lua << EOF
function openGithub()
  local function exec(cmd)
    -- shell out then strip trailing whitespace
    output = vim.call('system', cmd):gsub("%s*$", "")
    if (vim.v.shell_error ~= 0) then error(string.format("'%s' failed: %s", cmd, output)) end
    return output
  end

  -- TODO check if ssh or https. will assume ssh for now.
  originURL  = exec('git remote get-url origin'):gsub("git@github.com:", "https://github.com/"):gsub("%.git", "")
  defaultBranch = exec("git remote show origin | sed -n '/HEAD branch/s/.*: //p'")
  pathInRepo = exec(string.format("git ls-files --full-name %s", vim.fn.expand('%')))
  currentLineNum = unpack(vim.api.nvim_win_get_cursor(0))
  githubURL = string.format("%s/blob/%s/%s#L%s", originURL, defaultBranch, pathInRepo, currentLineNum)
  exec(string.format('open "%s"', githubURL))
end

function formatX509Cert()
  max_length = 75
  wrapped_lines = {"-----BEGIN CERTIFICATE-----"}
  current_line = vim.api.nvim_get_current_line():gsub("^%s*", ""):gsub("%s*$", "")
  while string.len(current_line) > max_length do
    table.insert(wrapped_lines, current_line:sub(1,max_length))
    current_line = current_line:sub(max_length + 1, -1)
  end
  table.insert(wrapped_lines, current_line)
  table.insert(wrapped_lines, "-----END CERTIFICATE-----")

  vim.api.nvim_buf_set_lines(vim.api.nvim_get_current_buf(), 0, -1, true, wrapped_lines)
end
EOF
command OpenGithub lua openGithub()
command FmtCert lua formatX509Cert()

" Keyword completion is my most-used coc feature for most file types.
" On machines where I wouldn't normally have node installed, this keyword
" completion is pretty similar to what coc gives us, but without the bloat!
" My main gripes about the built-in completion are that entering the
" completion sub-mode is visually distracting, opening the popup menu can be
" slow when synchronously loading keywords from large buffers, coc is
" smarter about opening the popup menu, and coc supports fuzzy matching
" keyword suggestions.
function KeywordCompletion()
  " open completion menu when insert mode is entered, or <space> is pressed, or kk  is pressed
  autocmd InsertEnter * :call feedkeys("\<C-n>\<C-p>", 'n')
  " disable the auto pairs plugin from creating an imapping for <space>
  let g:AutoPairsMapSpace = 0
  inoremap <space> <space><C-n><C-p>
  inoremap <expr> kk pumvisible() ? "\<lt>Down>\<lt>CR>" : "\<lt>C-n>\<lt>C-p>"

  " completion menu options
  set completeopt=longest,menuone
  " display no more than 10 suggestions at a time
  set pumheight=10
endfunction


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

" underscores in markdown files are incorrectly being highlighted as syntax
" errors. this removes the annoying false positives, but may ignore other
" markdown syntax errors.
hi link markdownError Normal

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
nmap <silent> <Leader>Q :bd!<CR>

" jiangmiao/auto-pairs: don't do auto pairs for single and double quotes
let g:AutoPairs = {'(':')', '[':']', '{':'}', '```':'```', '"""':'"""', "'''":"'''", "`":"`"}

" directory-wide replace all instances of 'old' with 'new'
function GlobalReplace(old, new)
  execute "args `rg" a:old "-l` | argdo %s/" . a:old . "/" . a:new . "/g | up"
endfunction

" ALE
" only lint on save
let g:ale_lint_on_text_changed = 'never'
let g:ale_fix_on_save = 1
" fixing legacy code sometimes results in huge diffs. don't automatically fix
" often-legacy filetypes
autocmd Filetype ruby let g:ale_fix_on_save = 0
autocmd Filetype typescript let g:ale_fix_on_save = 0
autocmd Filetype yaml let g:ale_fix_on_save = 0
" all of the linters need to be installed in order to work. ALE will not warn
" if they are enabled but not installed. Some of the Go linters come with the
" Go installation (e.g. gofmt) but others need to be installed separately.
let g:ale_linters = {
\   'go': ['gopls', 'golint', 'gofmt', 'govet', 'goimports'],
\}
let g:ale_fixers = {
\   '*': ['trim_whitespace'],
\   'go': ['gofmt', 'goimports'],
\   'html': ['prettier'],
\   'javascript': ['prettier'],
\   'markdown': ['prettier'],
\   'python': ['black'],
\   'ruby': ['rubocop'],
\   'yaml': ['prettier'],
\}
" can renable these as needed
" \   'typescript': ['prettier'], " large diffs with legacy code
autocmd Filetype go,typescript nmap gd :ALEGoToDefinition<CR>

" COC (coc.nvim)
" rename symbol using LSP
nmap <leader>r <Plug>(coc-rename)
" this is needed for the custom popup menu added in 0.0.82. without the coc#pum#info
" logic, <CR> closes the pum but does not insert a newline when no suggestions
" are selected. It is a (unpleasant) way to see if a suggestion has been selected.
" `"suggest.noselect": true` is also needed in the CocConfig to prevent
" suggestions from automatically being selected.
inoremap <silent><expr> <CR> coc#pum#visible() && coc#pum#info()['index'] != -1 ? coc#pum#confirm() : "\<CR>"
" insert the first suggestion with kk
inoremap <silent><expr> kk coc#pum#visible() ? coc#_select_confirm() : "kk"


" pgsql.vim. treat all sql files as postgres.
let g:sql_type_default = 'pgsql'

" nvim-treesitter
lua << EOF
  require'nvim-treesitter.configs'.setup {
    -- A list of parser names, or "all"
    ensure_installed = { "hcl", "markdown", "markdown_inline" },
    highlight = {
      enable = true,
      additional_vim_regex_highlighting = false,
    },
  }
EOF

" opsort.vim
" NOTE: use `gs` to sort selected text. in particular, visual block selection.

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
abbreviate teh the
abbreviate livermap liveramp
abbreviate ssolrcom sso.liveramp.com
abbreviate taht that

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

" disable netrw history
let g:netrw_dirhistmax = 0

" automatically continue comment leader when hitting <Enter> in insert mode or
" `o`/`O` in normal mode. see `:h fo-table` for more.
set formatoptions+=r formatoptions+=o
