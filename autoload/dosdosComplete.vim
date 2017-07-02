scriptencoding utf-8

if !has('win32')
  finish
endif

function! s:splitn(str)
  return split(a:str, '\v\r\n|\n|\r')
endfunction

function! s:complePos(regexp)
  let [line, col] = [getline('.'), col('.') - 1]
  while col > 0 && line[col - 1] =~# a:regexp
    let col -= 1
  endwhile
  return col
endfunction

function! s:listDosHelp() abort
  let [ret, res] = [[], s:splitn(iconv(system('help'), 'cp932', &enc))]
  let lower = get(g:, 'dosdos_complete_lower', 1)
  for i in range(len(res))
    let line = res[i]
    if line[0] =~# '\v\C[A-Z]'
      let pos  = matchend(line, '\v[A-Z]+')
      let cmd  = strpart(line, 0, pos)
      let line = strpart(line, pos)
      call add(ret, [lower ? tolower(cmd) : cmd, ''])
    endif
    if line =~# '\v^\s+'
      let ret[len(ret) - 1][1] .= strpart(line, matchend(line, '\v^\s+'))
    endif
  endfor
  return ret
endfunction

function! s:dosbatchComplete(findstart, base) abort
  if !exists('s:dosHelp')
    let s:dosHelp = s:listDosHelp()
  endif
  if a:findstart
    return s:complePos('\v\C[a-zA-Z]')
  endif
  let ret = []
  for [word, menu] in s:dosHelp
    if stridx(toupper(word), toupper(a:base)) is 0
      call add(ret, {'word': word, 'menu': menu})
    endif
  endfor
  return ret
endfunction

function! dosdosComplete#Complete(findstart, base)
  return s:dosbatchComplete(a:findstart, a:base)
endfunction
