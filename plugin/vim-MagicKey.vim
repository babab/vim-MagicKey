" vim: set fdm=marker fmr="++,"+-:
"
" Vim MagicKey plugin - Perform various actions depending on line content
"
" Copyright (c) 2014 Benjamin Althues <benjamin@babab.nl>
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
" Version:    0.1

" '#' will be expanded to the comment char(s) of the filetype
let g:magickey_foldmarker = '#++,#+-'
let g:magickey_foldsectionlength = 78

function! MkGetCommandChar()
    if &filetype ==# 'vim'
        return '"'
    elseif &filetype ==# 'php'
        return '//'
    elseif &filetype ==# 'javascript'
        return '//'
    elseif &filetype ==# 'html'
        return "<!--"
    else
        return '#'
    endif
endfunction

function! MkFoldMarkerStart()
    let foldmarkers = split(g:magickey_foldmarker, ',')
    return substitute(l:foldmarkers[0], '#', MkGetCommandChar(), '')
endfunction

function! MkFoldMarkerEnd()
    let foldmarkers = split(g:magickey_foldmarker, ',')
    return substitute(l:foldmarkers[1], '#', MkGetCommandChar(), '')
endfunction

function! MkFoldSectionAdd()
    let name = input("Section name: ")
    if l:name ==# '' | echo "-- aborting --" | return 0 | endif

    let tail = MkFoldMarkerEnd()
    let taillength = g:magickey_foldsectionlength - strlen(l:tail)
    call append('.', l:tail)
    execute "normal! j" . l:taillength . "A-\<Esc>k"

    call append('.', '') | call append('.', '') | call append('.', '')

    let head = MkFoldMarkerStart() . ' ' . l:name . ' '
    let headlength = g:magickey_foldsectionlength - strlen(l:head)
    call append('.', l:head)
    execute "normal! j" . l:headlength . "A-\<Esc>jj"
endfunction

function! MkFoldSectionUpdate()
    substitute/\s\+$//e
    let currline = getline('.')
    let headlength = g:magickey_foldsectionlength - strlen(l:currline) - 1
    call setline('.', l:currline)
    execute "normal! A \<Esc>" . l:headlength . "A-\<Esc>"
endfunction

function! MkBumpCopyright()
    let curr_year = strftime("%Y")
    let prev_year = l:curr_year - 1
    let ln = getline('.')

    if match(l:ln, 'Copyright') ==# -1
        return 0
    elseif match(l:ln, l:curr_year) ># -1
        return 0
    endif

    if match(l:ln, '-' . l:prev_year) ># -1
        call setline('.', substitute(l:ln, l:prev_year, l:curr_year, ''))
    elseif match(l:ln, l:prev_year) ># -1
        call setline('.', substitute(l:ln, l:prev_year,
                    \ l:prev_year . '-' . l:curr_year, ''))
    endif
endfunction

function! MagicKey()
    let cmd = ''
    let nmatches = 0
    let ln = getline('.')

    if match(l:ln, '^' . MkFoldMarkerEnd()) ># -1
        let l:cmd .= "MkFoldSectionAdd() "
        let l:nmatches += 1
    endif
    if match(l:ln, '^' . MkFoldMarkerStart()) ># -1
        let l:cmd .= "MkFoldSectionUpdate() "
        let l:nmatches += 1
    endif
    if match(l:ln, 'Copyright') ># -1
        let l:cmd .= "MkBumpCopyright() "
        let l:nmatches += 1
    endif

    if l:nmatches ==# 1
        execute "call " . l:cmd
        echom "MagicKey called " . l:cmd
    elseif l:nmatches >=# 2
        echo ' '
        echo 'MagicKey: ambigious content, choose action: '
        echo ' '
        let options = split(l:cmd, ' ')
        let nopt = 1
        for i in l:options
            echo 'Option '. l:nopt . ': ' . i
            let nopt += 1
        endfor
        echo ' '
        let inp = input("Select option number: ")
        let opt = get(l:options, l:inp -1, "none")
        if l:opt !=# "none"
            execute "call " . l:opt
        else
            echo ' '
            echo "Invalid option"
        endif
    else
        echo "MagicKey does not recognize content"
    endif
endfunction


command! FoldSectionAdd     call MkFoldSectionAdd()
command! FoldSectionUpdate  call MkFoldSectionUpdate()
command! BumpCopyright      call MkBumpCopyright()


nnoremap <silent> <Return> :call MagicKey()<CR>
