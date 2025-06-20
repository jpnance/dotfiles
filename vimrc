augroup filetypePhp
  autocmd!
  autocmd FileType php :setlocal suffixesadd=.php
augroup END

augroup filetypeTypescript
  autocmd!
  autocmd FileType typescript :setlocal suffixesadd=.ts,.d.ts,.tsx,.js,.jsx,.cjs,.mjs,.json
augroup END

function! AutoReader()
  augroup autoReader
    autocmd!
    autocmd CursorHold,InsertEnter *.vue,*.ts,*.js :checktime
  augroup END

  set autoread
  set updatetime=1000
endfunction

function! ColorScheme()
  let g:jellybeans_overrides = {
  \	'background': { 'ctermbg': 'none', '256ctermbg': 'none' },
  \ 'VertSplit': { 'guifg': '333333' },
  \ 'StatusLineNC': { 'guibg': '333333', 'guifg': '999999' },
  \ 'StatusLine': { 'guibg': '555555', 'guifg': 'ffffff' },
  \}

  if has('termguicolors') && &termguicolors
    let g:jellybeans_overrides['background']['guibg'] = 'none'
  endif

  set t_Co=256

  colorscheme jellybeans
endfunction

function! Defaults()
  set nocompatible

  filetype plugin on

  set noswapfile

  delmarks!
  delmarks A-Z0-9

  set path+=**

  set grepprg=git\ grep\ -n\ $*\ --\ ':!*translations*'\ ':!*js_routes*'

  syntax on
  set regexpengine=0

  set hlsearch
  set incsearch
endfunction

function! Git()
  command! GitDiffDevelopArgs execute 'args ' . join(filter(split(system('git diff --name-only origin/develop...'), "\n"), 'filereadable(v:val)'), " ") | ls
endfunction

function! Gui()
  augroup cursorLineFocus
    autocmd!
    autocmd WinEnter * :set cursorline
    autocmd WinLeave * :set nocursorline
  augroup END

  augroup autoResizer
    autocmd!
    autocmd VimResized * exe "normal \<c-w>="
  augroup END

  set number
  set relativenumber

  set splitbelow
  set splitright

  set wildmenu
  set wildmode=list:longest,full
  set wildignore+=**/node_modules/**,**/dist/**

  set mouse=a

  set list
  set listchars=leadmultispace:\ ┊,tab:▸\ 

  set fillchars=vert:│,fold:-,eob:~,lastline:@

  set cursorline
endfunction

function! Indentation()
  set tabstop=2
  set shiftwidth=2
  set expandtab
  set autoindent
  set smartindent
endfunction

function! Path()
  function! IgnoreFirstDirectory(fname)
    return join(split(a:fname, '/')[1:], '/')
  endfunction

  let pwd = getcwd()

  if pwd =~ "Workspace/chess"
    let pathsWeCareAbout = ["/client/web/**", "/client/shared/**", "/client/tests/**", "/client/types/**", "/src/Chess/WebBundle/**", "/src/Chess/CoreBundle/**"]
    let &path = join(map(pathsWeCareAbout, { i, path -> pwd .. path}), ',')
    set includeexpr=IgnoreFirstDirectory(v:fname)
  endif
endfunction

function! StatusLine()
  augroup statusLine
    autocmd!
    autocmd InsertEnter * :highlight StatusLine ctermfg=16 ctermbg=251 guibg=#ffffff guifg=#333333
    autocmd InsertLeave * :highlight StatusLine ctermfg=231 ctermbg=239 guibg=#555555 guifg=#ffffff
  augroup END

  function! IsCurrentBufferModified()
    let currentBufferInfo = getbufinfo(bufname())

    return currentBufferInfo[0].changed
  endfunction

  " Very useful links for this stuff
  " http://got-ravings.blogspot.com/2008/08/vim-pr0n-making-statuslines-that-own.html
  " https://shapeshed.com/vim-statuslines/
  set laststatus=2
  set statusline=
  set statusline+=\ 
  set statusline+=%f\ 
  set statusline+=%m
  set statusline+=%h
  set statusline+=%r
  set statusline+=%=
  set statusline+=%l:%c\ 
endfunction

function! TabCompletion()
  function! InsertTabWrapper()
      let col = col('.') - 1
      if !col
          return "\<tab>"
      endif

      let char = getline('.')[col - 1]
      if char =~ '\k'
          " There's an identifier before the cursor, so complete the identifier.
          return "\<c-p>"
      else
          return "\<tab>"
      endif
  endfunction

  inoremap <expr> <tab> InsertTabWrapper()
  inoremap <s-tab> <c-n>
endfunction

function! UsefulMappings()
  function! QuickfixFilterInteractive()
    let l:pattern = input('Filter quickfix entries (prefix ! to remove matches): ')
    if empty(l:pattern)
      echo "No pattern entered. Aborting."
      return
    endif

    " If pattern starts with !, invert the match and remove the !
    let l:keep_matches = 1
    if l:pattern[0] ==# '!'
      let l:keep_matches = 0
      let l:pattern = l:pattern[1:]
    endif

    let Matcher = {v ->
          \ (has_key(v, 'filename') && v.filename =~ l:pattern)
          \ || (has_key(v, 'bufnr') && bufname(v.bufnr) =~ l:pattern)
          \ || (has_key(v, 'text') && v.text =~ l:pattern)
          \ }

    let l:filtered = l:keep_matches
          \ ? filter(getqflist(), {_, v -> Matcher(v)})
          \ : filter(getqflist(), {_, v -> !Matcher(v)})

    call setqflist(l:filtered)
    redraw
    echo len(l:filtered) . " quickfix entries kept."
  endfunction

  function! GrepAndOpenQF()
    let l:query = input('Grep for: ')

    if empty(l:query)
      return
    endif

    execute 'silent! grep! ' . shellescape(l:query)
    redraw!

    if len(getqflist()) > 0
      copen
    else
      echo "No results found."
    endif
  endfunction

  let g:mapleader="\<Space>"

  noremap <C-w>x :%!xxd<CR>
  noremap <C-w>X :%!xxd -r<CR>
  noremap <C-w>m :!man ./%<CR>
  noremap <C-w>z :tabnew %<CR>

  nnoremap <Leader>b :b 
  nnoremap <Leader>f :find 

  nnoremap <Leader>/ :call GrepAndOpenQF()<CR>
  nnoremap <Leader>* :grep! <cword><CR><CR>:copen<CR>
  nnoremap <Leader>cf :call QuickfixFilterInteractive()<CR>
  nnoremap <Leader>c1 :cfirst<CR>
  nnoremap <Leader>co :copen<CR>
  nnoremap <Leader>cc :cclose<CR>
  nnoremap <Leader>[ :cprevious<CR>
  nnoremap <Leader>] :cnext<CR>
  nnoremap <Leader>{ :colder<CR>
  nnoremap <Leader>} :cnewer<CR>

  nnoremap <Leader>lo <Nop>
  nnoremap <Leader>lc <Nop>
  nnoremap <Leader>lgr <Nop>
  " nnoremap <Leader>lo :lopen<CR>
  " nnoremap <Leader>lc :lclose<CR>
  " nnoremap <Leader>lgr :lgrep! 
  " nnoremap <Leader>* :lgrep! <cword><CR><CR>:lopen<CR>

  nnoremap <Leader>gf :e client/<cfile>

  nnoremap <Leader>y "*y
  vnoremap <Leader>y "*y

  nnoremap <Leader>y% :let @*=expand('%')<CR>

  nnoremap <Leader>dd 0D

  inoremap <C-C> <Esc>

  nnoremap <Leader>e :e ~/.vimrc<CR>
  nnoremap <Leader>v :source ~/.vimrc<CR>

  nnoremap <Leader>: :%s/<C-R><C-W>//g<Left><Left>

  nnoremap <Leader>gd :GitDiffDevelopArgs<CR>

  nnoremap <Leader><Esc> :nohlsearch<CR>
endfunction

call AutoReader()
call ColorScheme()
call Defaults()
call Git()
call Gui()
call Indentation()
call Path()
call StatusLine()
call TabCompletion()
call UsefulMappings()
