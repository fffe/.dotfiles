syntax on
filetype plugin indent on

set background=dark
set showmode 
set laststatus=2                " always show the statusline
set expandtab                   " 4 space tabs
set tabstop=4
set softtabstop=4
set shiftwidth=4
set virtualedit=all             " free the cursor
set iskeyword+=_,$,@-@,%,#,-    " also consider these part of a word
set showmatch                   " highlight matching brackets
set matchtime=3
set formatoptions-=t            " don't auto-wrap text by default
set scrolloff=6                 " keep this many lines visible above/below cursor while scrolling
set noerrorbells                " don't beep or blink
set novisualbell
set t_vb=

" highlight .md as markdown instead of modula-2
autocmd BufNewFile,BufReadPost *.md set filetype=markdown

" filename [filetype] [encoding] [readonly modified] [modified][help][readonly] col row filepos buffer#
hi StatusLine term=none ctermfg=darkblue ctermbg=white
hi StatusLineNC term=none ctermfg=darkblue ctermbg=white
hi VertSplit term=none ctermfg=darkblue ctermbg=white
set statusline=%<%f\ %y\ [%{strlen(&fenc)?&fenc:&enc}]\ %m%h%r%=col=%c%V\ row=%l/%L\ %P\ [#%n]

" different setting for plain text or email
au BufEnter * call Checkfiletype()
func! Checkfiletype()
    if &filetype == ""
        setlocal fileformats=unix
        setlocal noautoindent
        setlocal nosmartindent
        setlocal noshowmatch            " don't show matching brackets for text files
        setlocal noexpandtab            " use actual tabs for tabs
        setlocal spell spelllang=en
        setlocal textwidth=70           " max line length 70 chars
        setlocal formatoptions+=t       " wrap lines longer than textwidth
    endif
    return
endfunc

" really write the file.
cmap w!! w !sudo tee % >/dev/null

" source a local config file if it exists
if !empty(glob("~/.vimrc.local"))
    source ~/.vimrc.local
endif
