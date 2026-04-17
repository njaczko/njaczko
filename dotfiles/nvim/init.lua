-- Nick Jaczko's (www.github.com/njaczko) neovim configuration file.
-- nvim expects to find this file at ~/.config/nvim/init.lua

-- bootstrap lazy.nvim
local lazypath = vim.fn.stdpath('data') .. '/lazy/lazy.nvim'
if not vim.loop.fs_stat(lazypath) then
  vim.fn.system({
    'git', 'clone', '--filter=blob:none', 'https://github.com/folke/lazy.nvim.git', '--branch=stable', lazypath,
  })
end
vim.opt.rtp:prepend(lazypath)

require('lazy').setup({
  {
    'njaczko/nvim-misc',
    lazy = false, priority = 1000, -- make sure to load this before all the other start plugins
    config = function()
      require('configure-retrobox').configureRetrobox()
    end,
  },
  {
    'jose-elias-alvarez/buftabline.nvim',
    config = function()
      require('buftabline').setup {
        tab_format = ' #{b} ',
        auto_hide = true,
        hlgroups = {normal = 'Comment'}
      }
    end
  },
  {
    'dense-analysis/ale',
    config = function()
      vim.g.ale_lint_on_text_changed = 'never' -- only lint on save
      vim.g.ale_virtualtext_cursor = 0
      vim.g.ale_fix_on_save = 1
      -- all of the linters need to be installed in order to work. ALE will not warn
      -- if they are enabled but not installed. Some of the Go linters come with the
      -- Go installation (e.g. gofmt) but others need to be installed separately.
      vim.g.ale_linters = {
         go = { 'golangci-lint', 'gopls', 'gofmt', 'govet', 'goimports' },
         ruby = { 'rubocop' },
      }
      vim.g.ale_fixers = {
        ['*'] = { 'remove_trailing_lines', 'trim_whitespace' },
        go = { 'gofmt', 'goimports' },
        jsonnet = { 'jsonnetfmt' },
        markdown = { 'prettier', 'trim_whitespace', 'remove_trailing_lines' },
        python = { 'black' },
        yaml = { 'prettier' },
      }
      vim.g.jsonnet_fmt_on_save = 0 -- disable vim-jsonnet formatting. ALE takes care of it.
    end
  },
  {'easymotion/vim-easymotion', event =  'VeryLazy'}, -- easymotion
  'https://tpope.io/vim/repeat.git', -- repeat commands
  'https://tpope.io/vim/surround.git', -- smart braces, parens, quotes, etc.
  {
    'ibhagwan/fzf-lua',
    event = 'VeryLazy',
    config = function()
      require('fzf-lua').setup {'default', blines={previewer=false}}
      vim.api.nvim_set_keymap('n', 'M', ':FzfLua blines<CR>', { noremap = true, silent = true })
      vim.api.nvim_set_keymap('n', '<C-p>', ':FzfLua files<CR>', { noremap = true, silent = true })
      vim.api.nvim_create_user_command( 'Rg', function() vim.cmd('FzfLua grep_project') end, {})
      vim.api.nvim_create_user_command( 'HelpTags', function() vim.cmd('FzfLua helptags') end, {})
    end
  },
  {'tpope/vim-fugitive',  cmd = 'Git' },
  'ralismark/opsort.vim', -- sort lines based on visual selection
  {
    'nvim-treesitter/nvim-treesitter',
    branch = 'main',
    lazy = false,
    build = ':TSUpdate',
    config = function()
      require('nvim-treesitter').install { 'go', 'gomod', 'gosum', 'hcl', 'jsonnet', 'ruby', 'sql', 'json', 'powershell' }
      vim.api.nvim_create_autocmd( 'FileType', {
        callback = function(ev)
          pcall(vim.treesitter.start, ev.buf)
        end
      })
      -- this is necessary to layer the custom note highlighting on top of the Treesitter markdown highlighting.
      vim.api.nvim_create_autocmd( 'FileType', {
        pattern = 'markdown.mdnotes',
        callback = function(ev)
          vim.treesitter.start(ev.buf, 'markdown')
          vim.bo[ev.buf].syntax = 'ON'
        end
      })
    end
  },
  {
    'dkarter/bullets.vim', -- automatic bullet list formatting
    ft = 'markdown',
    config = function()
      -- disable alphabetic lists.
      vim.g.bullets_max_alpha_characters = 0
      vim.g.bullets_enabled_file_types = { 'markdown', 'markdown.mdnotes' }
      vim.api.nvim_create_autocmd("FileType", {
        pattern = { "markdown", "markdown.mdnotes" },
        callback = function(ev)
          vim.keymap.set("i", "<Tab>", "<Plug>(bullets-demote)", { buffer = ev.buf })
          vim.keymap.set("i", "<S-Tab>", "<Plug>(bullets-promote)", { buffer = ev.buf })
          -- an imperfect solution for inserting bullets above the current line. doesn't
          -- work for the top bullet in a list.
          vim.keymap.set("n", "O", "k<Plug>(bullets-newline)", { buffer = ev.buf })
        end,
      })
    end,
  },
  {'AndrewRadev/inline_edit.vim',  cmd = 'InlineEdit' },
  'njaczko/auto-pairs', -- smart braces, parens, brackets
  'njaczko/nvim-dummy-text',
  {
    'hrsh7th/nvim-cmp',
    event = 'VeryLazy',
    dependencies = {
      'hrsh7th/cmp-buffer',
      'hrsh7th/cmp-path',
      'hrsh7th/cmp-nvim-lsp',
    },
    config = function()
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
              -- The default keyword_pattern, [[\%(-\?\d\+\%(\.\d\+\)\?\|\h\w*\%([\-.]\w*\)*\)]],
              -- does not match words containing dots, such as `foo.bar`. The
              -- regex below matches words containing dots/dashes/underscores.
              -- e.g. the literals `01GY5WGP959RKBBTQ12JV0WQ09`, `123.123`,
              -- `-123.123`, `foo.bar`, `foo-bar`, `foo_bar` are all matched.
              keyword_pattern = [[\w*\%([\-.]\w*\)*\w]],
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
      vim.opt.completeopt = { 'menu', 'menuone', 'noselect' }
      vim.opt.pumheight = 10
    end,
  },
  {'stevearc/oil.nvim', cmd = 'Oil', opts = {}},
  'mracos/mermaid.vim',
  -- {'google/vim-jsonnet',  ft = 'jsonnet' },
  -- 'leafgarland/typescript-vim',
  -- {'mbbill/undotree',  cmd = 'UndotreeToggle' },
})

vim.lsp.config['gopls'] = {
  cmd = {'gopls'},
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

vim.diagnostic.config({
  signs = {
    severity = { min = vim.diagnostic.severity.ERROR },
  },
  underline = {
    severity = { min = vim.diagnostic.severity.ERROR },
  },
})

vim.cmd([[
  autocmd Filetype * setlocal tabstop=2 expandtab shiftwidth=2 smarttab
  autocmd Filetype rst setlocal tabstop=3 shiftwidth=3 expandtab
  autocmd Filetype diff,c,go,python,typescript,sql,rust setlocal tabstop=4 expandtab shiftwidth=4 smarttab
  " tabs instead of spaces in makefiles.
  autocmd FileType make set noexpandtab
  autocmd FileType help,man set number
  autocmd Filetype go,tex set spell noexpandtab
  autocmd FileType markdown set textwidth=80
  autocmd FileType gitcommit set textwidth=50

  autocmd BufNewFile,BufRead *.tsx set ft=typescript
  autocmd BufNewFile,BufRead *.pegjs set ft=pegjs
  autocmd BufNewFile,BufRead *.tf set ft=hcl
  autocmd BufNewFile,BufRead *.hcl set ft=hcl
  autocmd BufNewFile,BufRead *.geojson set ft=json
  autocmd BufNewFile,BufRead Jenkinsfile set ft=groovy
  autocmd BufNewFile,BufRead *.bw set ft=bitwarden

  autocmd BufNewFile,BufRead ~/.focus_files setlocal commentstring=#\ %s
  autocmd FileType sql setlocal commentstring=--\ %s
  autocmd FileType smarty setlocal commentstring=#\ %s

  " MAPPINGS #####################################################################

  map <c-j> 10j
  map <c-k> 10k
  " yank to clipboard
  map Y "+y
  nnoremap K :w<CR>
  vnoremap K <NOP>
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
  autocmd Filetype markdown.mdnotes nmap a ^wi
  " textwidth wrap all the lines in the file
  nmap gQ ggVGgq
  " wrap a long line without having to enter visual mode
  nmap gq Vgq
  "retain selection after `>` and `<`
  vnoremap > >gv
  vnoremap < <gv
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
  " jumping to definitions, references, and implementations
  nmap gr :lua vim.lsp.buf.references()<CR>
  nmap gtd :lua vim.lsp.buf.type_definition()<CR>
  nmap gti :lua vim.lsp.buf.implementation()<CR>
  autocmd Filetype go nmap gd :lua vim.lsp.buf.definition()<CR>
  autocmd Filetype help nmap gd <C-]>
  " show signature
  nmap <leader>h :lua vim.lsp.buf.hover()<CR>
  " switching windows. nvim 0.10 added default <c-w> mappings that conflict
  " with the one I'm used to. Stomp on them because I don't expect to use them.
  unmap <c-w><c-d>
  unmap <c-w>d
  nnoremap <c-w> <c-w><c-w>

  " lazy.nvim will only load the easymotion plugin when one of these commands is
  " run. if you want to use other easymotion commands you'll have to add them to
  " the list or load the plugin all the time (~7-10ms).
  " easymotion search for 1 char
  nmap m <Plug>(easymotion-bd-f)

  " switching buffers
  nmap <silent> <c-h> :bprev!<CR>
  nmap <silent> <c-l> :bnext!<CR>
  " close current buffer.
  nmap <silent> <Leader>q :bd<CR>
  nmap <silent> <Leader>Q :bd!<CR>


  " COMMANDS #####################################################################

  " I can't figure out how to get the warning-level diagnostic messages to show
  " up in the location list or below the status line like the error messages
  " do. so, for now, make it easy to toggle
  command ShowDiagVirtualText :lua vim.diagnostic.config({virtual_text = true})<CR>
  command HideDiagVirtualText :lua vim.diagnostic.config({virtual_text = false})<CR>

  " turn on spell checking (use [s and ]s to move between misspelled words)
  command Spell set spell
  " turn off spell checking
  command Nospell set spell &
  command StripWhitespace %s/\s\+$//e
  command Wrap set wrap
  command Nowrap set nowrap
  command Norel set norelativenumber
  command Rel set relativenumber

  " directory-wide replace all instances of 'old' with 'new'
  function GlobalReplace(old, new)
    execute "args `rg" a:old "-l` | argdo %s/" . a:old . "/" . a:new . "/g | up"
  endfunction
  command -nargs=* GlobalReplace call GlobalReplace(<f-args>)

  command Source source $MYVIMRC
  command -nargs=* Cal r !cal -h <args>

  command -range=% FmtJson <line1>,<line2>!jq
  command -range=% FmtXML <line1>,<line2>!python3 -c "import xml.dom.minidom, sys; print(xml.dom.minidom.parse(sys.stdin).toprettyxml())"
  " Wrap lines with quotes, append commas
  command -range=% FmtList silent <line1>,<line2>s/^/"/g | <line1>,<line2>s/$/",/g | noh

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
  command FmtBullets %s/•\|◦\|▸\|▹\|▪\|▫/-/g
  command FmtQuotes %s/“\|”/"/ge |  %s/‘\|’/'/ge
  command SmartQuotes %s/ "/ “/ge |  %s/"/”/ge
  command FmtShellOutput %s/➜.*)/$/ge | %s/✗\|➜//ge | %s/<<<//ge
  command -range=% -nargs=1 Count :<line1>,<line2>s/<args>//gn

  " highlight the git merge conflict markers
  command MergeConflicts /<<<<<<<\|=======\|>>>>>>>

  command Python !python3 %
  command Make w | make
  command -bang Q q
  command -bang Qa qa

  " persist folds between sessions
  " views saved in ~/.local/share/nvim/view
  " makes a view for every file that is opened
  autocmd BufWinLeave * if &buftype != 'terminal' | silent! mkview | endif
  autocmd BufWinEnter * if &buftype != 'terminal' | silent! loadview | endif

  " close location list when closing buffer
  autocmd BufWinEnter quickfix nnoremap <silent> <buffer> q :cclose<cr>:lclose<cr>
  autocmd BufEnter * if (winnr('$') == 1 && &buftype ==# 'quickfix' ) | bd | q | endif
  autocmd BufWinEnter quickfix set spell &

  " sorts the selected lines by line length
  command -range=% SortLinesByLength <line1>,<line2>! awk '{ print length(), $0 | "sort -n | cut -d\\  -f2-" }'

  " SETTINGS AND MISCELLANEOUS ###################################################

  set mouse=nv
  " only search in open folds
  set fdo-=search

  " matching parens hurts performance and it's distracting
  let g:loaded_matchparen=1
  NoMatchParen

  " hybrid relative line numbers, except in terminal mode.
  set number relativenumber
  augroup numbertoggle
    autocmd!
    autocmd BufEnter,FocusGained,InsertLeave * if &buftype != 'terminal' | set relativenumber | endif
    autocmd BufLeave,FocusLost,InsertEnter   * if &buftype != 'terminal' | set norelativenumber | endif
  augroup END

  abbreviate TOOD TODO
  abbreviate adn and
  abbreviate exaclty exactly
  abbreviate iferr if err != nil {<CR><Left>
  abbreviate ot to
  abbreviate probaly probably
  abbreviate shoudl should
  abbreviate taht that
  abbreviate teh the
  abbreviate tehm them
  abbreviate wiht with
  abbreviate wtih with
  abbreviate vimft vim: ft=markdown.mdnotes foldmethod=marker

  " handling case in search
  set ignorecase
  set smartcase

  " show file name in status line
  set statusline=%f

  " Use persistent history to allow undo after file close
  if !isdirectory("/tmp/.vim-undo-dir")
      call mkdir("/tmp/.vim-undo-dir", "", 0700)
  endif
  set undofile undodir=/tmp/.vim-undo-dir
  " disable undofiles for some files that might contain secrets
  autocmd BufEnter /private* set noundofile
  autocmd BufEnter /tmp* set noundofile
  autocmd BufEnter *.private set noundofile
  autocmd FileType bitwarden set noundofile

  " disable netrw history
  let g:netrw_dirhistmax = 0

  " automatically continue comment leader when hitting <Enter> in insert mode or
  " `o`/`O` in normal mode. see `:h fo-table` for more.
  set formatoptions+=r formatoptions+=o

  " terminal mode settings
  autocmd TermOpen  * setlocal nonumber norelativenumber statusline=zsh
  " show max amount of output in terminal mode
  set scrollback=100000

  " disable blinking cursor in terminal mode, which became default in nvim 0.11
  set guicursor-=t:block-blinkon500-blinkoff500-TermCursor

  set scrolloff=5

  " prevent `gq` formatting from using LSP, like `gofmt`
  autocmd LspAttach * set formatexpr= formatprg=

  " Stop applying syntax highlighting after the 200th column. This helps
  " rendering performance for really long lines.
  autocmd FileType yaml,json set synmaxcol=200
]])
