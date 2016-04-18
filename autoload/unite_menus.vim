let g:unite_source_menu_menus = {
      \   'menus': {
      \     'description': 'menus menu'
      \   }
      \ }

nmap <Leader>/ :Unite -silent menu:menus<CR>

function! s:Get_open_menu_command(key) abort
  return 'Unite -silent menu:'.a:key
endfunction

function! s:Get_command_action(candidate)
  let command_action = 'execute'
  if has_key(a:candidate, 'command_action')
    let command_action = a:candidate['command_action']
  endif

  return command_action
endfunction

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
          \   'action__command': s:Get_open_menu_command(a:key),
          \ }
  endfunction
endfunction

function! s:Define_keymappings(name, menu_keymap, candidates) abort
  exec 'nmap '.a:menu_keymap.' :'.s:Get_open_menu_command(a:name).'<CR>'
  exec 'nmap '.a:menu_keymap.'/ :'.s:Get_open_menu_command(a:name).'<CR>'

  for key in keys(a:candidates)
    let candidate = a:candidates[key]

    if has_key(candidate, 'keymap')
      let cmd = candidate['command']
      let keymap = candidate['keymap']

      let keymap_cmd = 'nmap '.keymap.' :'.cmd

      let command_action = s:Get_command_action(candidate)
      if command_action == 'execute'
        let keymap_cmd = keymap_cmd.'<CR>'
      endif

      exec keymap_cmd
    endif
  endfor
endfunction

function! unite_menus#Map_candidates(key, value) abort
  let keymap = ''
  if has_key(a:value, 'keymap')
    let keymap = a:value['keymap']
  endif

  let item_description = printf('▷ %-40s %37s', a:key, keymap)

  let command_action = s:Get_command_action(a:value)
  if command_action == 'complete'
    return {
          \   'word': item_description,
          \   'kind': 'command_completion',
          \   'action__command': a:value['command']
          \ }
  endif

  return {
        \   'word': item_description,
        \   'kind': 'command',
        \   'action__command': a:value['command']
        \ }
endfunction

function! unite_menus#Define(name, description, keymap, candidates) abort
  let menu_description = printf('▷ %-40s %37s', a:description, a:keymap)
  let g:unite_source_menu_menus = extend(g:unite_source_menu_menus, {
        \   a:name : {
        \     'description': menu_description,
        \     'candidates': a:candidates,
        \     'map': function("unite_menus#Map_candidates"),
        \   }
        \ })

  " This will recalculate the menus menu every new menu added
  call s:Redefine_unite_menu_menus()

  call s:Define_keymappings(a:name, a:keymap, a:candidates)
  return 1
endfunction

