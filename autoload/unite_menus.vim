let g:unite_source_menu_menus = {
      \   'menus': {
      \     'description': 'Menus Menu',
      \     'candidates': [],
      \   }
      \ }

nmap <Leader>/ :Unite -silent menu:menus<CR>

function! s:Get_command_action(candidate) abort
  let command_action = 'execute'
  if has_key(a:candidate, 'command_action')
    let command_action = a:candidate['command_action']
  endif

  return command_action
endfunction

function! s:Get_keymaps(candidate, menu_keymap) abort
  let keymaps = []
  if has_key(a:candidate, 'keymap')
    call add(keymaps, printf('%s%s', a:menu_keymap, a:candidate['keymap']))
  endif
  if has_key(a:candidate, 'global_keymap')
    call add(keymaps, a:candidate['global_keymap'])
  endif

  return keymaps
endfunction

function! s:Get_menu_item_word(description, keymaps) abort
  return printf('▷ %-40s %37s', a:description, join(a:keymaps, ' '))
endfunction

function! s:Handle_candidate(key, candidate, menu_keymap) abort
  let keymaps = s:Get_keymaps(a:candidate, a:menu_keymap)
  let command_action = s:Get_command_action(a:candidate)

  " Keymap definition
  for keymap in keymaps
    let cmd = a:candidate['command']
    let keymap_cmd = 'nmap '.keymap.' :'.cmd

    if command_action == 'execute'
      let keymap_cmd = keymap_cmd.'<CR>'
    endif

    exec keymap_cmd
  endfor

  let new_candidate = {
        \   'word': s:Get_menu_item_word(a:key, keymaps),
        \   'kind': 'command',
        \   'action__command': a:candidate['command']
        \ }

  if command_action == 'complete'
    let new_candidate['kind'] = 'command_completion'
  endif

  return new_candidate
endfunction

function! s:Handle_candidates(menu_keymap, candidates) abort
  let new_candidates = []

  for key in sort(keys(a:candidates))
    let candidate = a:candidates[key]
    call add(new_candidates, s:Handle_candidate(key, candidate, a:menu_keymap))
  endfor

  return new_candidates
endfunction

function! unite_menus#Define(name, description, keymap, candidates) abort
  let g:unite_source_menu_menus = extend(g:unite_source_menu_menus, {
        \   a:name : {
        \     'description': a:description,
        \     'candidates': s:Handle_candidates(a:keymap, a:candidates),
        \   }
        \ })

  let open_menu_command = 'Unite -silent menu:'.a:name
  call add(g:unite_source_menu_menus.menus.candidates, {
        \   'word': s:Get_menu_item_word(a:description, [a:keymap]),
        \   'kind': 'command',
        \   'action__command': open_menu_command,
        \ })

  exec 'nmap '.a:keymap.' :'.open_menu_command.'<CR>'
  exec 'nmap '.a:keymap.'/ :'.open_menu_command.'<CR>'
  return 1
endfunction

