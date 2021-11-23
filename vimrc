set autochdir
set cursorline
set noswapfile

syntax on
set number
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
