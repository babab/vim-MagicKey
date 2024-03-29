" vim: set fdm=marker fmr="++,"+-:
"
" Vim MagicKey plugin - Perform various actions depending on line content
"
" Copyright (c) 2014-2023  Benjamin Althues <benjamin@babab.nl>
"
" Permission to use, copy, modify, and distribute this software for any
" purpose with or without fee is hereby granted, provided that the above
" copyright notice and this permission notice appear in all copies.
"
" THE SOFTWARE IS PROVIDED "AS IS" AND THE AUTHOR DISCLAIMS ALL WARRANTIES
" WITH REGARD TO THIS SOFTWARE INCLUDING ALL IMPLIED WARRANTIES OF
" MERCHANTABILITY AND FITNESS. IN NO EVENT SHALL THE AUTHOR BE LIABLE FOR
" ANY SPECIAL, DIRECT, INDIRECT, OR CONSEQUENTIAL DAMAGES OR ANY DAMAGES
" WHATSOEVER RESULTING FROM LOSS OF USE, DATA OR PROFITS, WHETHER IN AN
" ACTION OF CONTRACT, NEGLIGENCE OR OTHER TORTIOUS ACTION, ARISING OUT OF
" OR IN CONNECTION WITH THE USE OR PERFORMANCE OF THIS SOFTWARE.

" Maintainer: Benjamin Althues <http://babab.nl/>
" Version:    0.3

"++ Settings -----------------------------------------------------------------

" '#' will be expanded to the comment char(s) of the filetype
let g:magickey_foldmarker = '#++,#+-'
let g:magickey_maxlinelength = 78
let g:magickey_rst_headers = {1: '=', 2: '-', 3: '#', 4: '*', 5: '^', 6: '.'}
let g:magickey_rulerchars = ['*', '=', '-', '.', '"', "'", '#', ':', '\^', '~']

"+----------------------------------------------------------------------------
"++ Private functions --------------------------------------------------------

function! s:GetCommentPrefix()
    if &l:filetype ==# 'html'
        return "<!--"
    elseif &l:filetype ==# 'javascript'
        return '//'
    elseif &l:filetype ==# 'php'
        return '//'
    elseif &l:filetype ==# 'vim'
        return '"'
    else
        return '#'
    endif
endfunction

function! s:FoldMarkerStart()
    let foldmarkers = split(g:magickey_foldmarker, ',')
    return substitute(l:foldmarkers[0], '#', s:GetCommentPrefix(), '')
endfunction

function! s:FoldMarkerEnd()
    let foldmarkers = split(g:magickey_foldmarker, ',')
    return substitute(l:foldmarkers[1], '#', s:GetCommentPrefix(), '')
endfunction

"+----------------------------------------------------------------------------
"++ FoldSection functions ----------------------------------------------------

function! MkFoldSectionAdd()
    let name = input("Section name: ")
    if l:name ==# '' | echo "-- aborting --" | return 0 | endif

    let tail = s:FoldMarkerEnd()
    let taillength = g:magickey_maxlinelength - strlen(l:tail)
    call append('.', l:tail)
    execute "normal! j" . l:taillength . "A-\<Esc>k"

    call append('.', '') | call append('.', '') | call append('.', '')

    let head = s:FoldMarkerStart() . ' ' . l:name . ' '
    let headlength = g:magickey_maxlinelength - strlen(l:head)
    call append('.', l:head)
    execute "normal! j" . l:headlength . "A-\<Esc>jj"
endfunction

function! MkFoldSectionUpdate()
    substitute/\s\+$//e
    let currline = getline('.')
    let headlength = g:magickey_maxlinelength - strlen(l:currline) - 1
    call setline('.', l:currline)
    execute "normal! A \<Esc>" . l:headlength . "A-\<Esc>"
endfunction

"+----------------------------------------------------------------------------
"++ BumpCopyright ------------------------------------------------------------

function! MkBumpCopyright()
    let curr_year = strftime("%Y")
    let prev_year = l:curr_year - 1
    let ln = getline('.')

    if match(l:ln, 'Copyright') ==# -1
        return 0
    elseif match(l:ln, l:curr_year) ># -1
        echo "No need to bump copyright"
        return 0
    endif

    if match(l:ln, '-' . l:prev_year) ># -1
        call setline('.', substitute(l:ln, l:prev_year, l:curr_year, ''))
    elseif match(l:ln, l:prev_year) ># -1
        call setline('.', substitute(l:ln, l:prev_year,
                    \ l:prev_year . '-' . l:curr_year, ''))
    endif
endfunction

"+----------------------------------------------------------------------------
"++ Horizontal ruler ---------------------------------------------------------

function! MkHorizontalRuler(...)
    let fillchar = a:0 == 1 ? a:1 : 'none'

    if l:fillchar ==# 'none'
        for i in g:magickey_rulerchars
            if len(substitute(getline('.'), '[' . i . ']', '', 'g')) ==# 0
            \ && len(substitute(getline('.'), '[^' . i . ']', '', 'g')) ># 4
                let l:fillchar = getline('.')[0]
                break
            endif
        endfor
    endif

    execute "normal! ^D" . g:magickey_maxlinelength . "A"
        \ . l:fillchar . "\<Esc>"
endfunction

"+----------------------------------------------------------------------------
"++ Markdown / reStructuredText ----------------------------------------------

function! MkMarkdownHeaderToRst()
    if match(getline('.'), '^#.') ==# -1 | return 0 | endif

    let nmatches = len(split(getline('.'), '#', 1)) - 1
    let headingchar = get(g:magickey_rst_headers, l:nmatches, "none")
    if l:headingchar !=# "none"
        execute "normal! ^dwYpVr" . l:headingchar
        echo "Expanded markdownheader to rst header h" . l:nmatches
    else
        echo "You can only use 1-6 dashes"
    endif
endfunction

"+----------------------------------------------------------------------------
"++ Python functions from vim_MagicKey.py ------------------------------------

" Add plugin to path
python3 import sys
python3 import vim
python3 sys.path.append(vim.eval('expand("<sfile>:h")'))
python3 import vim_MagicKey

function! MkRunCommand()
    python3 vim_MagicKey.MkRunCommand(vim)
endfunction

function! MkReplace()
    python3 vim_MagicKey.MkReplace(vim)
endfunction

"+----------------------------------------------------------------------------
"++ Main MagicKey() function -------------------------------------------------

function! MagicKey()
    let cmd = ''
    let ln = getline('.')

    let triggers = {}
    let l:triggers['MkFoldSectionAdd()'] = '^' . s:FoldMarkerEnd()
    let l:triggers['MkFoldSectionUpdate()'] = '^' . s:FoldMarkerStart()
    let l:triggers['MkBumpCopyright()'] = 'Copyright'
    let l:triggers['MkRunCommand()'] = '^# mkrun: '
    let l:triggers['MkReplace()'] = '^# mkreplace: '

    for i in g:magickey_rulerchars
        if len(substitute(getline('.'), '[' . i . ']', '', 'g')) ==# 0
        \ && len(substitute(getline('.'), '[^' . i . ']', '', 'g')) ># 4
            let l:fillchar = getline('.')[0]
            let l:triggers["MkHorizontalRuler('" . l:fillchar . "')"] = '^.'
            break
        endif
    endfor

    if &l:filetype ==# 'rst'
        let l:triggers['MkMarkdownHeaderToRst()'] = '^#\+.\a\+'
    endif

    for [callable, pattern] in items(l:triggers)
        if match(l:ln, pattern) ># -1
            let l:cmd .= callable . ' '
        endif
    endfor

    let options = split(l:cmd, ' ')
    let nmatches = len(l:options)

    if l:nmatches ==# 1
        execute "call " . l:cmd
    elseif l:nmatches >=# 2
        echo 'MagicKey: ambigious content, choose action: '
        let nopt = 1
        for i in l:options
            echo 'Option '. l:nopt . ': ' . i
            let nopt += 1
        endfor
        let inp = input("Select option number: ")
        let opt = get(l:options, l:inp -1, "none")
        if l:opt ==# "none"
            echo "Invalid option"
        else
            execute "call " . l:opt
        endif
    else
        echo "MagicKey does not recognize content"
    endif
endfunction

"+----------------------------------------------------------------------------
"++ Commands and keymapping --------------------------------------------------

command! FoldSectionAdd         call MkFoldSectionAdd()
command! FoldSectionUpdate      call MkFoldSectionUpdate()
command! BumpCopyright          call MkBumpCopyright()
command! HorizontalRuler        call MkHorizontalRuler()
command! MarkdownHeaderToRst    call MkMarkdownHeaderToRst()
command! RunCommand             call MkRunCommand()
command! ReplaceInAllBuffers    call MkReplace()

nnoremap <silent> <Return> :call MagicKey()<CR>

"+----------------------------------------------------------------------------
