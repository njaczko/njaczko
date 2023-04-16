" Nick Jaczko's (www.github.com/njaczko) neovim configuration file.
" nvim expects to find this file at ~/.config/nvim/init.vim

" manage plugins with vim-plug
call plug#begin('~/.local/share/nvim/plugged')
Plug 'morhetz/gruvbox' " color scheme
Plug 'udalov/kotlin-vim', { 'for': 'kotlin' } " kotlin syntax highlighting
Plug 'google/vim-jsonnet', { 'for': 'jsonnet' }
Plug 'leafgarland/typescript-vim'
Plug 'ap/vim-buftabline'
Plug 'evanleck/vim-svelte', {'branch': 'main', 'for': 'svelte'} " svelte syntax highlighting
Plug 'dense-analysis/ale' " async linting engine
Plug 'easymotion/vim-easymotion', { 'on': ['<Plug>(easymotion-bd-f)', '<Plug>(easymotion-sn)'] } " easymotion
Plug 'https://tpope.io/vim/repeat.git' " repeat commands
Plug 'https://tpope.io/vim/surround.git' " smart braces, parens, quotes, etc.
Plug 'junegunn/fzf'
Plug 'junegunn/fzf.vim'
Plug 'tpope/vim-fugitive', { 'on': 'Git' }
Plug 'mbbill/undotree', { 'on': 'UndotreeToggle' }
Plug 'tpope/vim-commentary' " block commenting
Plug 'lifepillar/pgsql.vim', { 'for': 'sql' } " postgres syntax highlighting
Plug 'ralismark/opsort.vim' " sort lines based on visual selection
Plug 'nvim-treesitter/nvim-treesitter' " LSP syntax highlighting, etc.
Plug 'dkarter/bullets.vim', { 'for': 'markdown' } " automatic bullet list formatting
Plug 'AndrewRadev/inline_edit.vim', { 'on': 'InlineEdit' }
Plug 'njaczko/vim-reslang'
Plug 'njaczko/auto-pairs' " smart braces, parens, brackets
Plug 'njaczko/nvim-dummy-text'
Plug 'njaczko/nvim-misc'
Plug 'hrsh7th/cmp-buffer'
Plug 'hrsh7th/nvim-cmp'
Plug 'hrsh7th/cmp-path'
Plug 'hrsh7th/cmp-nvim-lsp'
Plug 'neovim/nvim-lspconfig'
call plug#end()

" TABS, SPACES, AND FILETYPES ##################################################

autocmd Filetype * setlocal tabstop=2 expandtab shiftwidth=2 smarttab
autocmd Filetype rst setlocal tabstop=3 shiftwidth=3 expandtab
autocmd Filetype c,go,python,typescript setlocal tabstop=4 expandtab shiftwidth=4 smarttab
" tabs instead of spaces in makefiles.
autocmd FileType make set noexpandtab

autocmd FileType markdown set textwidth=80
autocmd FileType gitcommit set textwidth=50

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
autocmd Filetype markdown.markdownnotes nmap a ^wi
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
" rename token using LSP
nmap <leader>r :lua vim.lsp.buf.rename()<CR>
" show all references of token using LSP
nmap gr :lua vim.lsp.buf.references()<CR>
" TODO this waits for some reason. would a commad make more sense anyway?
" show signature
nmap gs :lua vim.lsp.buf.hover()<CR>

lua vim.lsp.buf.signature_help()


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
command -nargs=* Cal r !cal -h <args>

" prettify the selected json lines. requires https://github.com/stedolan/jq
command -range PrettyJson <line1>,<line2>!jq
" prettify xml
command! PrettyXML :%!python3 -c "import xml.dom.minidom, sys; print(xml.dom.minidom.parse(sys.stdin).toprettyxml())"

" highlight column 80. off by default because of screen burn in.
command Charbar highlight colorcolumn ctermbg=DarkGray | set colorcolumn=80
command Nocharbar set colorcolumn=

" do not redraw for commands that were not typed (e.g. mapping that enters
" visual mode and highlights)
set lazyredraw

" open an empty 40 column buffer to roughly center the current buffer on wide
" displays
command Center 40vsplit empty

" convert fancy bullet characters to dashes
command PlainBullets %s/•\|◦\|▸\|▹\|▪\|▫/-/g

" persist folds between sessions
" views saved in ~/.local/share/nvim/view
" makes a view for every file that is opened
autocmd BufWinLeave * silent! mkview
autocmd BufWinEnter * silent! loadview

" close location list when closing buffer
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

" nested bullets are confused for code blocks because they start with many
" spaces. code fenced with backticks is still highlighted.
highlight link markdownCodeBlock Normal
" some things that are technically invalid markdown syntax (like unescaped
" underscores) don't really cause issues for my use cases. the error
" highlights are more of a nuisance than a help for me.
hi link markdownError Normal
" syntax highlighting inside code blocks. can add more languages, these are
" just ones that I use often and have verified the highlighting works
" correctly
let g:markdown_fenced_languages = ['go', 'vim', 'bash', 'sql']

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
" switching buffers
" nmap <silent> <Left> :bprev!<CR>
" nmap <silent> <Right> :bnext!<CR>
nmap <silent> <c-h> :bprev!<CR>
nmap <silent> <c-l> :bnext!<CR>
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
let g:ale_virtualtext_cursor = 0
let g:ale_fix_on_save = 1
" all of the linters need to be installed in order to work. ALE will not warn
" if they are enabled but not installed. Some of the Go linters come with the
" Go installation (e.g. gofmt) but others need to be installed separately.
let g:ale_linters = {
\   'go': ['gopls', 'golint', 'gofmt', 'govet', 'goimports'],
\}
let g:ale_fixers = {
\   '*': ['remove_trailing_lines', 'trim_whitespace'],
\   'go': ['gofmt', 'goimports'],
\   'markdown': ['prettier'],
\   'python': ['black'],
\   'ruby': ['rubocop'],
\}
" NOTE: fixing legacy code sometimes results in huge diffs. don't
" automatically fix often-legacy filetypes. can renable these as needed:
" \   'markdown': ['prettier'],
" \   'html': ['prettier'],
" \   'javascript': ['prettier'],
" \   'typescript': ['prettier'], " large diffs with legacy code
" \   'yaml': ['prettier'],

autocmd Filetype go,typescript nmap gd :ALEGoToDefinition<CR>

" nvim-cmp
set completeopt=menu,menuone,noselect
set pumheight=10

lua <<EOF
  -- Set up nvim-cmp.
  local cmp = require'cmp'

  cmp.setup({
    preselect = cmp.PreselectMode.None,
    mapping = cmp.mapping.preset.insert({
      ['<C-k>'] = cmp.mapping.select_prev_item(), -- previous suggestion
      ['<C-j>'] = cmp.mapping.select_next_item(), -- next suggestion
      ['kk'] = cmp.mapping.select_next_item(), -- next suggestion
    }),
    sources = cmp.config.sources({
      { name = 'nvim_lsp' },
      { name = 'path' }, -- file system paths
      {
        name = 'buffer',
        option = {
          -- keyword_pattern = [[\%(-\?\d\+\%(\.\d\+\)\?\|\h\w*\%([\-.]\w*\)*\)]], --default
          -- matches words contain dots/dashes/underscores or postive/negative decimals.
          -- e.g. the literals `01GY5WGP959RKBBTQ12JV0WQ09`, `123.123`, `-123.123`,
          -- `foo.bar`, `foo-bar`, `foo_bar` are all matched. If we don't care about
          -- matching negative decimals, we can simply use `[[\w\w*\%([\-.]\w*\)*]]` instead.
          keyword_pattern = [[\%(\w\w*\%([\-.]\w*\)*\|-\?\d\+\%(\.\d\+\)\?\)]],
          get_bufnrs = function()
            -- poor performance indexing large files. Don't index files larger than max_size_megabytes MB
            local max_size_megabytes = 1
            local ret = {}
            for _, buf in pairs(vim.api.nvim_list_bufs()) do
              local byte_size = vim.api.nvim_buf_get_offset(buf, vim.api.nvim_buf_line_count(buf))
              if byte_size < 1024 * 1024 * max_size_megabytes then
                table.insert(ret, buf)
              end
            end
            return ret
          end
        }
      },
    })
  })

  local nvim_lsp = require('lspconfig')

  nvim_lsp['gopls'].setup{
    cmd = {'gopls'},
    on_attach = on_attach,
    capabilities = capabilities,
    settings = {
      gopls = {
        experimentalPostfixCompletions = true,
        analyses = {
          unusedparams = true,
          shadow = true,
        },
        staticcheck = true,
      },
    },
    init_options = {
      usePlaceholders = true,
    }
  }
  -- adding neovim/lspconfig causes SignColumn signs and inline virtual text
  -- warnings to show up for language errors. I only want ALE to publish diagnostics
  vim.diagnostic.disable()
EOF

" pgsql.vim. treat all sql files as postgres.
let g:sql_type_default = 'pgsql'

" nvim-treesitter
lua << EOF
  require'nvim-treesitter.configs'.setup {
    -- A list of parser names, or "all"
    ensure_installed = { "hcl" },
    highlight = {
      enable = true,
      additional_vim_regex_highlighting = false,
    },
  }
EOF

" Bullets.vim
let g:bullets_enabled_file_types = [ 'markdown', 'markdown.markdownnotes' ]
autocmd Filetype markdown,markdown.markdownnotes inoremap <Tab> <Plug>(bullets-demote)
autocmd Filetype markdown,markdown.markdownnotes inoremap <S-Tab> <Plug>(bullets-promote)
" an imperfect solution for inserting bullets above the current line. doesn't
" work for the top bullet in a list.
autocmd Filetype markdown.markdownnotes nmap O k<Plug>(bullets-newline)
let g:bullets_outline_levels = ['ROM', 'ABC', 'num', 'abc', 'rom', 'std-']


" vim-jsonnet
let g:jsonnet_fmt_on_save = 0

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
abbreviate TOOD TODO

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

set foldmethod=manual
