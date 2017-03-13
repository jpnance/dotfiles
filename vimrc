syntax on
set number

if has('gui_running')
	set autochdir
	set cursorline
	colorscheme jellybeans

	map <C-w>t :browse tabnew<CR>
	map <C-w>e :browse e<CR>
	map <M-Left> :tabprev<CR>
	map <M-Right> :tabnext<CR>

	set guifont=Liberation\ Mono\ 9
 	set go=aegit
	set guitablabel=%t%(\ %M%)
	set guiheadroom=0
endif
