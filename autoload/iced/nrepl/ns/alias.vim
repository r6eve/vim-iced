let s:save_cpo = &cpo
set cpo&vim

let s:V = vital#iced#new()
let s:D = s:V.import('Data.Dict')

function! s:parse_to_alias_dict(resp) abort
  if !has_key(a:resp, 'value') || a:resp['value'][0] !=# '{'
    return {}
  endif

  let value = a:resp['value']
  let value = value[1:len(value)-2]

  let ls = split(value, ',\? ')
  let ls = map(ls, {i, v -> (i % 2) == 0 ? v : iced#nrepl#ns#util#extract_ns(v)})
  return s:D.from_list(ls)
endfunction

function! iced#nrepl#ns#alias#dict(ns) abort
  let code = printf('(ns-aliases ''%s)', a:ns)
  let resp = iced#nrepl#sync#send({
      \ 'op': 'eval',
      \ 'code': code,
      \ 'session': iced#nrepl#current_session(),
      \ })
  return s:parse_to_alias_dict(resp)
endfunction

function! iced#nrepl#ns#alias#dict_from_code(code) abort
  let resp = iced#nrepl#refactor#ns_parser#aliases(a:code)
  return s:parse_to_alias_dict(resp)
endfunction

let &cpo = s:save_cpo
unlet s:save_cpo