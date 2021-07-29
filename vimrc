set noswapfile

set autochdir
set cursorline

syntax on
set number

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

noremap <C-w>t :tabnew 
noremap <C-w>e :e 
noremap <C-w>x :%!xxd<CR>
noremap <C-w>X :%!xxd -r<CR>
noremap <C-w>m :!man ./%<CR>

set expandtab
set tabstop=2
set shiftwidth=2
set autoindent
set smartindent

set clipboard=unnamed

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

augroup filetypeVim
	autocmd!
	autocmd FileType vim :setlocal noexpandtab
augroup END
