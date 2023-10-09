filetype plugin on
set path+=**
set wildignore+=**/node_modules/**,**/dist/**
set grepprg=git\ grep\ -n\ $*

" set autochdir
set cursorline
set noswapfile

syntax on
set number
set relativenumber
set splitbelow
set splitright

let g:jellybeans_overrides = {
\	'background': { 'ctermbg': 'none', '256ctermbg': 'none' },
\}

if has('termguicolors') && &termguicolors
	let g:jellybeans_overrides['background']['guibg'] = 'none'
endif

set t_Co=256

if $VIM_ENVIRONMENT == "production"
	colorscheme blade_runner
else
	colorscheme jellybeans
endif

noremap <C-w>x :%!xxd<CR>
noremap <C-w>X :%!xxd -r<CR>
noremap <C-w>m :!man ./%<CR>

let mapleader="\<Space>"

nnoremap <Leader>co :copen<CR>
nnoremap <Leader>cc :cclose<CR>
nnoremap <Leader>/ :grep! 
nnoremap <Leader>* :grep! <cword><CR>

nnoremap <Leader>gf :e <cfile>
nnoremap <Leader>y "*y
nnoremap <Leader>y% :let @*=expand('%')<CR>

vnoremap <Leader>y "*y

set tabstop=4
set shiftwidth=4
set autoindent
set smartindent

if has('gui_running')
	noremap <C-w>t :browse tabnew<CR>
	noremap <C-w>e :browse e<CR>
	noremap <M-Left> :tabprev<CR>
	noremap <M-Right> :tabnext<CR>

	set guifont=Liberation\ Mono\ 9
 	set go=aegit
	set guitablabel=%t%(\ %M%)
	set guiheadroom=0
endif

set wildmenu
set wildmode=list:longest,full
set mouse=a

set listchars=tab:>-,trail:-

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

augroup cursorLineFocus
  autocmd!
  autocmd WinEnter * :set cursorline
  autocmd WinLeave * :set nocursorline
augroup END

augroup filetypeYaml
	autocmd!
	autocmd FileType yaml :setlocal expandtab
augroup END

augroup filetypePackageJson
	autocmd!
	autocmd FileType package.json :setlocal tabstop=2
	autocmd FileType package.json :setlocal shiftwidth=2
	autocmd FileType package.json :setlocal expandtab
augroup END
