augroup filetypePhp
  autocmd!
  autocmd FileType php :setlocal suffixesadd=.php
augroup END

augroup filetypeTypescript
  autocmd!
  autocmd FileType typescript :setlocal suffixesadd=.ts,.d.ts,.tsx,.js,.jsx,.cjs,.mjs,.json
  autocmd FileType typescript :setlocal formatoptions-=ro
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

  set background=dark
  colorscheme quiet
endfunction

function! Defaults()
  set nocompatible

  filetype plugin on

  set noswapfile

  delmarks!
  delmarks A-Z0-9

  set path+=**

  set grepprg=git\ grep\ -n\ $*\ --\ ':!*translations*'\ ':!*js_routes*'\ ':!*release-history.md*'

  syntax on
  set regexpengine=0

  set hlsearch
  set incsearch
endfunction

function! Git()
  " I might not need this on non-work machines
  " command! GitDiffDevelopArgs execute 'args ' . join(filter(split(system('git diff --name-only origin/develop...'), "\n"), 'filereadable(v:val)'), " ") | ls
  command! GitDiffDevelopArgs call setqflist(map(systemlist('git diff --name-only origin/develop...'), '{ "filename": v:val, "lnum": 1, "col": 1, "text": "" }')) | copen

  " DiffHere: left = <base_ref> blob (scratch), right = local file (focused).
  function! DiffHere(...) abort
    " safe optional arg: first arg or default
    let l:base_ref = get(a:000, 0, 'origin/develop')

    " 1) Current buffer path
    let l:cur = expand('%:p')
    if empty(l:cur)
      echoerr "DiffHere: current buffer has no filename"
      return
    endif

    " 2) Directory to run git in (use file dir or cwd)
    let l:dir = fnamemodify(l:cur, ':h')
    if l:dir ==# '' | let l:dir = getcwd() | endif

    " 3) Get repo root (capture stderr)
    let l:cmd = 'git -C ' . fnameescape(l:dir) . ' rev-parse --show-toplevel 2>&1'
    let l:root_out = systemlist(l:cmd)
    if v:shell_error || empty(l:root_out)
      let l:msg = empty(l:root_out) ? 'git failed with no output' : join(l:root_out, "\n")
      echohl ErrorMsg
      echom 'DiffHere: unable to determine git repo root for ' . l:dir . ' -- ' . l:msg
      echohl None
      return
    endif
    let l:root = fnamemodify(l:root_out[0], ':p')

    " 4) Repo-relative path for git show
    let l:rel = substitute(l:cur, '^' . escape(l:root, '\') , '', '')

    " 5) Fetch blob from base_ref (capture stderr)
    let l:showcmd = 'git --no-pager -C ' . fnameescape(l:root) . ' show ' . shellescape(l:base_ref . ':' . l:rel) . ' 2>&1'
    let l:blob = systemlist(l:showcmd)
    if v:shell_error
      let l:errtext = join(l:blob, "\n")
      echohl WarningMsg
      echom 'DiffHere: git show failed: ' . l:errtext
      echohl None
      let l:blob = [''] " ensure we still create an empty buffer for diff
    endif

    execute 'tabnew'

    " 6) Ensure we start by populating the left window with the base blob.
    " Use enew to get a fresh buffer then set it to be scratch and populate it.
    " (We avoid using vsplit first to keep deterministic left/right.)
    execute 'enew'
    setlocal buftype=nowrite bufhidden=wipe noswapfile nobuflisted
    call setline(1, l:blob)
    execute 'file ' . fnameescape('[' . l:base_ref . '] ' . l:rel)

    " 7) Open the local file to the right explicitly (regardless of 'splitright')
    " 'rightbelow vsplit' ensures the new window appears to the right of the current window.
    execute 'rightbelow vsplit'
    execute 'edit ' . fnameescape(l:cur)

    " 8) Move focus to the right window (local file)
    wincmd l

    " 9) Enable diff mode if not already on
    if &diff == 0
      windo diffthis
    endif

    " 10) Jump to first diff hunk (in the right window)
    silent! normal! ]c
  endfunction

  command! -nargs=? DiffHere call DiffHere(<f-args>)
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
  set listchars=leadmultispace:┊\ ,tab:▸\ 

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
    " use when using jellybeans color scheme
    "autocmd InsertEnter * :highlight StatusLine ctermfg=16 ctermbg=251 guibg=#ffffff guifg=#333333
    "autocmd InsertLeave * :highlight StatusLine ctermfg=231 ctermbg=239 guibg=#555555 guifg=#ffffff

    " use when using quiet color scheme
    "autocmd InsertEnter * :highlight StatusLine cterm=reverse
    "autocmd InsertLeave * :highlight StatusLine cterm=bold
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
  nnoremap <Up> :cprevious<CR>
  nnoremap <Down> :cnext<CR>
  nnoremap <Left> :colder<CR>
  nnoremap <Right> :cnewer<CR>

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

  nnoremap <Leader>y% :let @*="https://github.com/ChessCom/chess/tree/develop/" . expand('%') . "#L" . line(".")<CR>

  nnoremap <Leader>dd 0D

  inoremap <C-C> <Esc>

  nnoremap <Leader>e :e ~/.vimrc<CR>
  nnoremap <Leader>v :source ~/.vimrc<CR>

  nnoremap <Leader>: :%s/<C-R><C-W>//g<Left><Left>

  nnoremap <Leader>gd :GitDiffDevelopArgs<CR>
  nnoremap <Leader>vd :DiffHere<CR>

  nnoremap <Leader><Esc> :nohlsearch<CR>

  nnoremap <Leader>b/ ?function<CR>V/{<CR>%<ESC>/\%V
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
