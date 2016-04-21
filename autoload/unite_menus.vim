let g:unite_source_menu_menus = {
      \   'menus': {
      \     'description': 'Menus Menu',
      \     'candidates': [],
      \   }
      \ }

let g:unite_menus_keymap = '<Leader>/'
exec 'nmap '.g:unite_menus_keymap.' :Unite -silent menu:menus<CR>'

function! s:Get_command_action(candidate) abort
  let command_action = 'execute'
  if has_key(a:candidate, 'command_action')
    let command_action = a:candidate['command_action']
  endif

  return command_action
endfunction

function! s:Get_relative_keymaps(menu_keymap, relative_keymaps)
  let keymaps = []

  if type(a:relative_keymaps) == type([])
    for relative_keymap in a:relative_keymaps
      call add(keymaps, printf('%s%s', a:menu_keymap, relative_keymap))
    endfor
  else
    call add(keymaps, printf('%s%s', a:menu_keymap, a:relative_keymaps))
  endif

  return keymaps
endfunction

function! s:Get_keymaps(candidate, menu_keymaps) abort
  let keymaps = []

  if has_key(a:candidate, 'relative_keymap')
    if type(a:menu_keymaps) == type([])
      for menu_keymap in a:menu_keymaps
        let keymaps += s:Get_relative_keymaps(
              \   menu_keymap,
              \   a:candidate['relative_keymap']
              \ )
      endfor
    else
      let keymaps += s:Get_relative_keymaps(
            \   a:menu_keymaps,
            \   a:candidate['relative_keymap']
            \ )
    end
  endif

  if has_key(a:candidate, 'keymap')
    if type(a:candidate['keymap']) == type([])
      let keymaps += a:candidate['keymap']
    else
      call add(keymaps, a:candidate['keymap'])
    endif
  endif

  return keymaps
endfunction

function! s:Get_menu_item_word(description, keymaps) abort
  return printf('▷ %-40s %37s', a:description, join(a:keymaps, ' '))
endfunction

function! s:Handle_candidate(key, candidate, menu_keymaps) abort
  let keymaps = s:Get_keymaps(a:candidate, a:menu_keymaps)
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

function! s:Handle_candidates(menu_keymaps, candidates) abort
  let new_candidates = []

  for key in sort(keys(a:candidates))
    let candidate = a:candidates[key]
    call add(new_candidates, s:Handle_candidate(key, candidate, a:menu_keymaps))
  endfor

  return new_candidates
endfunction

function! unite_menus#Define(menus) abort
  for key in sort(keys(a:menus))
    let value = a:menus[key]

    let keymaps = s:Get_keymaps(value, g:unite_menus_keymap)
    let g:unite_source_menu_menus = extend(g:unite_source_menu_menus, {
          \   key : {
          \     'description': value.description,
          \     'candidates': s:Handle_candidates(keymaps, value.candidates),
          \   }
          \ })

    let open_menu_command = 'Unite -silent menu:'.key
    call add(g:unite_source_menu_menus.menus.candidates, {
          \   'word': s:Get_menu_item_word(value.description, keymaps),
          \   'kind': 'command',
          \   'action__command': open_menu_command,
          \ })


    for keymap in keymaps
      exec 'nmap '.keymap.' :'.open_menu_command.'<CR>'
      exec 'nmap '.keymap.'/ :'.open_menu_command.'<CR>'
    endfor
  endfor

  return 1
endfunction

