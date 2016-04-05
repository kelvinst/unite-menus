let g:unite_source_menu_menus = {
      \   'menus': {
      \     'description': '▷ This menu                                                            <Leader>m'
      \   }
      \ }

nmap <Leader>/ :Unite -silent -ignorecase menu:menus<CR>

function! s:Redefine_unite_menu_menus() abort
  let g:unite_source_menu_menus.menus.candidates = {}

  for key in keys(g:unite_source_menu_menus)
    if key != "menus"
      let g:unite_source_menu_menus.menus.candidates[key] =
            \ g:unite_source_menu_menus[key]
    endif
  endfor

  function! g:unite_source_menu_menus.menus.map(key, value)
    return {
          \   'word': a:value['description'],
          \   'kind': 'command',
          \   'action__command': 'Unite -silent -ignorecase menu:'.a:key
          \ }
  endfunction
endfunction

function! s:Map_candidates(key, value) abort
  let keys = ''
  if has_key(a:value, 'keymap')
    let keys = a:value['keymap']['keys']
  endif

  let item_description = printf('▷ %-40s %37s', a:value['description'],
        \ keys)

  return {
        \   'word': item_description,
        \   'kind': 'command',
        \   'action__command': a:value['command']
        \ }
endfunction

function! s:Define_keymappings(name, keymap, candidates) abort
  exec 'nmap '.a:keymap.' :Unite -silent -ignorecase menu:'.a:name.'<CR>'

  for key in keys(a:candidates)
    let candidate = a:candidates[key]

    if has_key(candidate, 'keymap')
      let cmd = candidate['command']
      let keymap = candidate['keymap']
      let keys = keymap['keys']

      let keymap_cmd = 'nmap '.keys.' :'.cmd
      if has_key(keymap, 'with_cr') && keymap['with_cr'] == 1
        let keymap_cmd = keymap_cmd.'<CR>'
      endif
      exec keymap_cmd
    endif
  endfor
endfunction

function! unite-menus#Define(name, description, keymap, candidates) abort
  let menu_description = printf('▷ %-40s %37s', a:description, a:keymap)
  let g:unite_source_menu_menus = extend(g:unite_source_menu_menus, {
        \   a:name : {
        \     'description': menu_description,
        \     'candidates': a:candidates,
        \     'map': function("s:Map_candidates"),
        \   }
        \ })

  " This will recalculate the menus menu every new menu added
  call s:Redefine_unite_menu_menus()

  call s:Define_keymappings(a:name, a:keymap, a:candidates)
  return 1
endfunction

