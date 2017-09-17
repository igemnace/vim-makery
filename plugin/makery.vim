""" DECLARATIONS {{{
" guard against multiple loaded instances
if exists("g:loaded_makery") || v:version < 700 || &cp
  finish
endif

" declare plugin has loaded
let g:loaded_makery = 1

" declare default config
let g:makery_config = get(g:, 'makery_config', {})

" declare default JSON config file name
let g:makery_json_filename = get(g:, 'makery_json_filename', '.makery.json')
""" END DECLARATIONS }}}

""" FUNCTIONS {{{
" checks if 'root' contains a filename 'file'
" taken from tpope's projectionist.vim
function! s:Has(root, file) abort
  let file = matchstr(a:file, '[^!].*')
  if file =~# '\*'
    let found = !empty(glob(a:root . '/' . file))
  elseif file =~# '/$'
    let found = isdirectory(a:root . '/' . file)
  else
    let found = filereadable(a:root . '/' . file)
  endif
  return a:file =~# '^!' ? !found : found
endfunction

" takes a 'path' and returns the simplest equivalent path string
" taken from tpope's projectionist.vim
function! s:NormalizePath(path) abort
  return simplify(fnamemodify(a:path, ':p:s?[\/]$??'))
endfunction

" ensures that all keys in 'config' are normalized
function! s:NormalizeConfig(config) abort
  let l:normalized_config = {}

  for [l:path, l:path_config] in items(a:config)
    let l:normalized_config[s:NormalizePath(l:path)] = l:path_config
  endfor

  return l:normalized_config
endfunction

" checks if user has declared makery config for the current working directory
function! s:DetectGlobalConfig() abort
  let l:normalized_config = s:NormalizeConfig(g:makery_config)
  let l:normalized_cwd = s:NormalizePath(getcwd())

  if has_key(l:normalized_config, l:normalized_cwd)
    let l:path_config = get(l:normalized_config, l:normalized_cwd)

    call makery#Setup(l:path_config)
  endif
endfunction

" checks if makery JSON config file exists in current working directory
function! s:DetectJSON() abort
  let l:normalized_cwd = s:NormalizePath(getcwd())

  if s:Has(l:normalized_cwd, g:makery_json_filename)
    try
      let l:json_path = l:normalized_cwd . '/' . g:makery_json_filename
      let l:path_config = json_decode(join(readfile(l:json_path)))

      call makery#Setup(l:path_config)
    catch
      echom 'makery.vim: Invalid JSON file detected.'
    endtry
  endif
endfunction
""" END FUNCTIONS }}}

if v:version >= 800 || exists('*json_decode')
  call s:DetectJSON()
endif
call s:DetectGlobalConfig()

" vim:fdm=marker
