" returns Make if such a command exists, to allow for async
function! s:GetMakeCommand() abort
  return exists(':Make') == 2 ? 'Make' : 'make'
endfunction

" executes :make/:Make with the given 'bang' and 'args'
function! s:ExecuteMake(bang, args) abort
  let l:make_command = s:GetMakeCommand() . a:bang
  execute s:GetMakeCommand() a:args
endfunction

" sets compiler, makeprg, and errorformat based on the given 'options' dict
function! s:ApplyOptions(options) abort
  let l:save_options = {}

  if has_key(a:options, 'compiler')
    execute 'compiler' get(a:options, 'compiler')
  endif

  if has_key(a:options, 'makeprg')
    let l:save_options.makeprg = &l:makeprg
    let &l:makeprg = get(a:options, 'makeprg')
  endif

  if has_key(a:options, 'errorformat') && !has_key(a:options, 'compiler')
    let l:save_options.errorformat = &l:errorformat
    let &l:errorformat = get(a:options, 'errorformat')
  endif

  return l:save_options
endfunction

function! s:RestoreOptions(options) abort
  for [l:option, l:value] in items(a:options)
    execute 'let &l:' . l:option '= "' . l:value . '"'
  endfor
endfunction

function! s:debug(msg) abort
  if get(g:, 'makery_debug')
      echom a:msg
  endif
endfunction

" applies 'options', calls the make command, then restores applied options
function! makery#Make(options, bang, args) abort
  let l:save_options = s:ApplyOptions(a:options)
  call s:ExecuteMake(a:bang, a:args)
  call s:RestoreOptions(l:save_options)
endfunction

function! s:CreatePrefixedCommand(command, options) abort
  let l:command_name = 'M' . a:command

  if (exists(':' . l:command_name))
      call s:debug('makery.vim: Existing command :' . l:command_name . '. Skipping.')
      return
  endif

  execute 'command! -buffer -bang -nargs=* -complete=file' l:command_name
    \ 'call makery#Make(' . string(a:options) . ', <q-bang>, <q-args>)'
endfunction

function! s:CreateMainCommand() abort
  command! -buffer -bang -nargs=+ -complete=customlist,makery#CmdCompletion
    \ Makery call makery#ReceiveMakeryArgs(<q-bang>, <f-args>)
endfunction

" set up :M commands according to the given 'config'
function! makery#Setup(config) abort
  let b:makery_registry = extend(get(b:, 'makery_registry', {}), a:config)

  call s:CreateMainCommand()
  for [l:command, l:options] in items(a:config)
    call s:CreatePrefixedCommand(l:command, l:options)
  endfor
endfunction

function! makery#CmdCompletion(ArgLead, ...) abort
  let l:makery_registry = get(b:, 'makery_registry', {})

  return filter(keys(l:makery_registry), 'v:val =~? "' . a:ArgLead . '"')
endfunction

function! makery#ReceiveMakeryArgs(bang, command, ...) abort
  let l:options = get(b:makery_registry, a:command)
  let l:command_args = join(a:000[1:])

  call makery#Make(l:options, a:bang, l:command_args)
endfunction
