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
  if has_key(a:options, 'compiler')
    execute "compiler" get(a:options, 'compiler')
  endif

  if has_key(a:options, 'makeprg')
    let &l:makeprg = get(a:options, 'makeprg')
  endif

  if has_key(a:options, 'errorformat') && !has_key(a:options, 'compiler')
    let &l:errorformat = get(a:options, 'errorformat')
  endif
endfunction

" applies 'options', then calls the make command
function! makery#Make(options, bang, args) abort
  call s:ApplyOptions(a:options)
  call s:ExecuteMake(a:bang, a:args)
endfunction

function! s:CreateCommand(command, options) abort
  let l:command_name = 'M' . a:command
  
  if (exists(":" . l:command_name))
      echom "The command :" . l:command_name . " is already defined elsewhere."
  endif

  execute 'command! -bang -nargs=* -complete=file' l:command_name
    \ 'call makery#Make(' . string(a:options) . ', <q-bang>, <q-args>)'
endfunction

" set up :B commands according to the given 'config'
function! makery#Setup(config) abort
  for [l:command, l:options] in items(a:config)
    call s:CreateCommand(l:command, l:options)
  endfor
endfunction
