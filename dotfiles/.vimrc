autocmd Filetype * setlocal tabstop=2 expandtab shiftwidth=2 smarttab
autocmd Filetype notes,rst setlocal tabstop=3 shiftwidth=3 expandtab
autocmd Filetype c,go,python,typescript setlocal tabstop=4 expandtab shiftwidth=4 smarttab
autocmd FileType make set noexpandtab

map <c-j> 10j
map <c-k> 10k
" yank to clipboard
map Y "+y
nnoremap <c-w> <c-w><c-w>
nmap I eli
nmap W 5w
nmap B 5b
vmap W 5w
vmap B 5b
map a ^i
imap jj <Esc>
nnoremap K :w<CR>
vnoremap K <NOP>

" searching
set ignorecase
set smartcase
set hlsearch
nmap <silent> <Leader>n :noh<CR>

" show file name in status line
set laststatus=2
set statusline=%f

set noswapfile

syntax enable
set number

colorscheme slate
" black background
hi Normal ctermbg=None

" dependency-free versions of some of the searching commands I have in nvim.
" Rg recursively looks for matches in other files
command! -nargs=+ Rg vimgrep /<args>/ **/*.* | copen
" M looks for matches in the current file
command! -nargs=+ M vimgrep /<args>/ % | copen | /<args>
" close quickfix after making selection
autocmd FileType quickfix nnoremap <buffer> <CR> <CR>:cclose<CR>
