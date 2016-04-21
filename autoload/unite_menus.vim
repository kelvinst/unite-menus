let g:unite_menus_keymap = '<Leader>/'
let g:unite_menus_keymap_arguments = '<silent> <unique>'

let g:unite_source_menu_menus = {
      \   'menus': {
      \     'description': 'Menus Menu',
      \     'candidates': [],
      \   }
      \ }

function! s:Define_keymap(keymap, command, with_cr)
  let keymap_cmd = 'nmap '.g:unite_menus_keymap_arguments.' '.a:keymap
  let keymap_cmd = keymap_cmd.' :'.a:command
  if a:with_cr == 1
    let keymap_cmd = keymap_cmd.'<CR>'
  end

  exec keymap_cmd
endfunction

call s:Define_keymap(g:unite_menus_keymap, 'Unite -silent menu:menus', 1)

function! s:Get_kind(candidate) abort
  let kind = 'command'
  if has_key(a:candidate, 'kind')
    let kind = a:candidate['kind']
  endif

  return kind
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

function! s:Define_keymaps(candidate, menu_keymaps) abort
  let keymaps = s:Get_keymaps(a:candidate, a:menu_keymaps)
  let kind = s:Get_kind(a:candidate)

  for keymap in keymaps
    let with_cr = 0
    if kind == 'command'
      let with_cr = 1
    endif

    if has_key(a:candidate, 'action__command')
      call s:Define_keymap(keymap, a:candidate.action__command, with_cr)
    endif
  endfor

  return keymaps
endfunction

function! s:Handle_candidate(key, candidate, menu_keymaps) abort
  let keymaps = s:Define_keymaps(a:candidate, a:menu_keymaps)

  let new_candidate = extend(a:candidate, {
        \   'word': s:Get_menu_item_word(a:key, keymaps),
        \   'kind': s:Get_kind(a:candidate),
        \ })

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

    let parent_keymaps = []
    if has_key(value, 'parent_menu')
      let parent_name = value.parent_menu
      let parent_menu = g:unite_source_menu_menus[parent_name]

      let parent_keymaps = parent_menu._unite_menus.saved_keymaps
    else
      let parent_keymaps = [g:unite_menus_keymap]
    endif

    let keymaps = s:Get_keymaps(value, parent_keymaps)
    let g:unite_source_menu_menus = extend(g:unite_source_menu_menus, {
          \   key : {
          \     'description': value.description,
          \     'candidates': s:Handle_candidates(keymaps, value.candidates),
          \     '_unite_menus': {
          \       'saved_keymaps': keymaps
          \     },
          \   },
          \ })

    if has_key(value, 'parent_menu')
      let parent_name = value.parent_menu
      let parent_menu = g:unite_source_menu_menus[parent_name]

      call add(parent_menu.candidates, {
            \   'word': s:Get_menu_item_word(value.description, keymaps),
            \   'kind': 'menu',
            \   'action__menu': key,
            \ })
    else
      call add(g:unite_source_menu_menus.menus.candidates, {
            \   'word': s:Get_menu_item_word(value.description, keymaps),
            \   'kind': 'menu',
            \   'action__menu': key,
            \ })
    endif

    let open_menu_command = 'Unite -silent menu:'.key
    for keymap in keymaps
      call s:Define_keymap(keymap, open_menu_command, 1)
      call s:Define_keymap(keymap.'/', open_menu_command, 1)
    endfor
  endfor

  return 1
endfunction

