" returns Make if such a command exists, to allow for async
function! s:GetMakeCommand() abort
  return exists(':Make') == 2 ? 'Make' : 'make'
endfunction

" executes :make/:Make with the given 'bang' and 'args'
function! s:ExecuteMake(bang, args) abort
  let l:make_command = s:GetMakeCommand() . a:bang
  execute s:GetMakeCommand() a:args
endfunction

" executes :make with the given 'makeprg' and 'errorformat'
function! makery#Make(makeprg, errorformat, bang, args) abort
  let &l:makeprg = a:makeprg
  if a:errorformat
    let &l:errorformat = a:errorformat
  endif

  call s:ExecuteMake(a:bang, a:args)
endfunction

" executes :make with the given 'compiler'
function! makery#Compile(compiler, bang, args, ...) abort
  execute 'compiler' a:compiler
  if a:0 > 0
    let &l:makeprg = a:1
  endif

  call s:ExecuteMake(a:bang, a:args)
endfunction

" creates a :B command that uses 'makeprg' and 'errorformat'
function! makery#CreateMakeCommand(command, makeprg, errorformat) abort
  let l:command_name = 'M' . a:command

  execute 'command! -bang -nargs=*' l:command_name
    \ 'call makery#Make("' . a:makeprg . '", "' . a:errorformat . '", <q-bang>, <q-args>)'
endfunction

" creates a :B command that uses 'compiler'
function! makery#CreateCompileCommand(command, compiler, ...) abort
  let l:command_name = 'M' . a:command
  if a:0 > 0
    let l:makeprg = a:1

    execute 'command! -bang -nargs=*' l:command_name
          \ 'call makery#Compile("' . a:compiler . '", <q-bang>, <q-args>, "' . l:makeprg . '")'
  else
    execute 'command! -bang -nargs=*' l:command_name
          \ 'call makery#Compile("' . a:compiler . '", <q-bang>, <q-args>)'
  endif
endfunction

" set up :B commands according to the given 'config'
function! makery#Setup(config) abort
  for [l:command, l:options] in items(a:config)
    if has_key(l:options, 'compiler')
      let l:compiler = get(l:options, 'compiler')

      if has_key(l:options, 'makeprg')
        let l:makeprg = get(l:options, 'makeprg')

        call makery#CreateCompileCommand(l:command, l:compiler, l:makeprg)
      else
        call makery#CreateCompileCommand(l:command, l:compiler)
      endif
    else
      let l:makeprg = get(l:options, 'makeprg')
      let l:errorformat = get(l:options, 'errorformat')

      call makery#CreateMakeCommand(l:command, l:makeprg, l:errorformat)
    endif
  endfor
endfunction
