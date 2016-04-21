"=============================================================================
" FILE: menu.vim
" AUTHOR:  Kelvin Stinghen <kelvin.stinghen@gmail.com>
" License: MIT license  {{{
"     Permission is hereby granted, free of charge, to any person obtaining
"     a copy of this software and associated documentation files (the
"     "Software"), to deal in the Software without restriction, including
"     without limitation the rights to use, copy, modify, merge, publish,
"     distribute, sublicense, and/or sell copies of the Software, and to
"     permit persons to whom the Software is furnished to do so, subject to
"     the following conditions:
"
"     The above copyright notice and this permission notice shall be included
"     in all copies or substantial portions of the Software.
"
"     THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS
"     OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
"     MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT.
"     IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY
"     CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT,
"     TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE
"     SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
" }}}
"=============================================================================

let s:save_cpo = &cpo
set cpo&vim

function! unite#kinds#menu#define() abort "{{{
  return s:kind
endfunction"}}}

let s:kind = {
      \ 'name' : 'menu',
      \ 'default_action' : 'open',
      \ 'action_table': {},
      \}

" Actions "{{{
let s:kind.action_table.open = {
      \ 'description' : 'open menu',
      \ }
function! s:kind.action_table.open.func(candidate) abort "{{{
  let command = 'Unite -silent menu:'.a:candidate.action__menu
  let type = get(a:candidate, 'action__type', ':')
  if get(a:candidate, 'action__histadd', 0)
    call s:add_history(type, command)
  endif
  call s:execute_command(type . command)
endfunction"}}}
"}}}

function! s:add_history(type, command) abort "{{{
  call histadd(a:type, a:command)
  if a:type ==# '/'
    let @/ = a:command
  endif
endfunction"}}}
function! s:execute_command(command) abort "{{{
  let temp = tempname()
  try
    call writefile([a:command], temp)
    execute 'source' fnameescape(temp)
  catch /E486/
    " Ignore search pattern error.
  finally
    if filereadable(temp)
      call delete(temp)
    endif
  endtry
endfunction"}}}

let &cpo = s:save_cpo
unlet s:save_cpo

" vim: foldmethod=marker
