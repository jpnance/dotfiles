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

map <C-w>t :tabnew 
map <C-w>e :e 
map <C-w>x :%!xxd<CR>
map <C-w>X :%!xxd -r<CR>

set tabstop=4
set shiftwidth=4

if has('gui_running')
	map <C-w>t :browse tabnew<CR>
	map <C-w>e :browse e<CR>
	map <M-Left> :tabprev<CR>
	map <M-Right> :tabnext<CR>

	set guifont=Liberation\ Mono\ 9
 	set go=aegit
	set guitablabel=%t%(\ %M%)
	set guiheadroom=0
endif

set wildmenu
set wildmode=list:longest,full
set mouse=a

set listchars=tab:>-,trail:-
