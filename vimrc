set autochdir
set cursorline
set noswapfile

syntax on
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

noremap <C-w>b :ls<CR>:buffer 
noremap <C-w>t :tabnew 
noremap <C-w>e :e 
noremap <C-w>x :%!xxd<CR>
noremap <C-w>X :%!xxd -r<CR>
noremap <C-w>m :!man ./%<CR>

set tabstop=2
set shiftwidth=2
set expandtab
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

augroup filetypeYaml
	autocmd!
	autocmd FileType yaml :setlocal tabstop=4
	autocmd FileType yaml :setlocal shiftwidth=4
	autocmd FileType yaml :setlocal expandtab
augroup END

augroup filetypeVue
	autocmd!
	autocmd FileType vue :setlocal suffixesadd=.vue,.ts,.d.ts,.tsx,.js,.jsx,.cjs,.mjs
augroup END
