set nocompatible              "We want the latest vim settings/options 

syntax enable
filetype plugin on

"-------------General Settings--------------"
set backspace=indent,eol,start                                          "Make backspace behave like every other editor.
let mapleader = ','                   "The default leader is \, but a comma is much better.
set relativenumber                "Let's activate line numbers.
set number                "Let's activate line numbers.
set autowriteall              "Automatically write the file when switching buffers
set complete=.,w,b,u              "Set our desired autocompletion
set tabstop=2
set expandtab
set softtabstop=2
set shiftwidth=2
set nowrap
set foldmethod=manual
autocmd BufWinLeave * mkview
autocmd BufWinEnter * silent! loadview
set showcmd               "Shows what's typing
set path+=**                                                          " search down into subfolders
set wildmenu                                                          " display all matching files when we tab complete
set textwidth=60
set colorcolumn=+1

"-------------Split Management--------------"
set splitbelow
set splitright

"-------------Search--------------"
set hlsearch
set incsearch

"-------------Mappings--------------" 

"Make it easy to edit the Vimrc file.
nmap <Leader>ev :tabedit $MYVIMRC<cr>
nmap <Leader>ep :tabedit ~/.vim/plugins.vim<cr>
nmap <Leader>es :e ~/.vim/snippets/<cr>

"Add simple highlight removal.
nmap <Leader><space> :nohlsearch<cr>

"Easy escaping to normal model
imap jj <esc>

" Prettify json
nmap <Leader>jp :%!python -m json.tool<CR>

" Map <Leader>r to replace selected expression with result using the = register
vnoremap <leader>e :<C-u>let @a = eval('"' . @")")<CR>"ap

"Automatically source the Vimrc file on save.
augroup autosourcing
  autocmd!
  autocmd BufWritePost .vimrc source %
augroup END
  
augroup CSVSettings
  autocmd!
  autocmd FileType csv setlocal noexpandtab tabstop=8 shiftwidth=8
  autocmd FileType tsv setlocal noexpandtab tabstop=8 shiftwidth=8
augroup END

"-------------Plugins--------------"  
let g:airline#extensions#tabline#enabled = 1    " Enable the list of buffers
let g:airline#extensions#tabline#fnamemod = ':t'" Show just the filename
let g:airline#extensions#tabline#formatter = 'unique_tail'
let g:vimwiki_folding = 'expr'

"/
"/ Notes & Tips
"/
" - 'zz' ca sa centreze linia pe care este cursorul.
" - '-' ca sa te duca in filesystem unde e fisierul.
" 
" " CTags
" - '!ctags -R' ca sa scanez tot folderul in care sunt 
" - '<c-]>' ca sa de duca unde este definita metoda pe care esti.
" - '<c-t>' ca sa revii unde erai cand ai apasat '<c-]>'
" - ',f cuvant' ca sa il caut in tot ctags 
" - 'ts' ca sa listez tot ce a gasit ',f cuvant' - 'tp' , 'tn' - sa navighez printre resultate
"
"" Autocomplietion
" - '<c-n>' anything in the 'complete' option
" - '<c-x><c-f>' files and paths
" - '<c-x><c-n>' search in current file
" - '<c-x><c-]>' search tags
"    '<c-n>'/'<c-p>' navigare printre rezultate
"
"" FileBrowsing
" - ':edit .' listeaza fisierele din folder 
"
"" Snippets   
"
"
" - 'Ag 'regex' ca sa caut prin tot proiectul
" - ':Gsearch' ca sa caut prin fisier. Face un fisier cu tot ce gaseste. Modific in el si dau ':Greplace'. ':wa' ca sa salvezi toate bufferele.
" - ':s/vechi/nou/gc ca sa caut toate potrivirile, sa le inlocuiesc si sa fiu intrebat de fiecare data.
" - 'cwo' ca sa faca fullscreen bufferul curent
" - 'cw|' ca sa faca fullscreen splitul curent
" - 'J' ca sa aduc linia de dedesubt
" - '<c-o>' ma duce pe unde am modificat chestii
" - '<c-i>' ma intoarce
" - 'mm' ca sa setez marcator m in fisierul asta. 'mM' ca sa setez marcator M in toate fisierele
" - 'M ca sa ma duc la linia marcata
" - `M ca sa ma duc la linia si coloana marcata
" - `0 ca sa revin la ultimul fisier in care lucram
" - ':marks' listeaza toti marcatorii setati
" - 'dat' delete a tag. vat/cat
" - 'yiw' copiaza cuvantul
" - 'qq' ca sa inregistrez in macroul q. q ca sa opresc inregistrarea.
" - ':reg' ca sa listez toate marcourile.
" - '@q' ca sa rulez ce-am inregistrat in q.
" - '"qp' ca sa arat tot ce-am inregistrat in q.
" - 'let @q=""' in .vimrc ca sa-l salvez
" - ':sh' ca sa deschid consola din vim. 'exit' ca ma ma intorc in vim.
" - '!ls' ca sa execut o comanda din shell.
" - 'H' cursor high. 'M' cursor middle. 'L' cursos low.
" - 'fa' ca sa gaseasca primul 'a' din linia curenta.
" - 'df.' ca sa stearga pana la primul . inclusiv
" - 'dt.' ca sa stearga pana la primul . exclusiv
" - "d'm" ca sa stearga pana la marcatorul m.
" - ':b name' deschide un buffer incarcate care are name in nume
" - ':find file' cauta un fisier in proiect. suporta tab si *
" - ':g/profile/d' sterge o linie ce contine cuvantul profile (se poate regex)
" - ':g!/profile/d' sterge o linie ce NU contine cuvantul profile
