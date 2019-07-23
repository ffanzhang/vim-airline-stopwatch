scriptencoding utf-8

if !has("timers")
  echoerr "stopwatch: requires vim with +timers feature"
  finish
endif

if !has("reltime")
  echoerr "stopwatch: requires vim with +reltime feature"
  finish
endif

if exists('g:loaded_vim_airline_stopwatch')
  finish
endif

let g:loaded_vim_airline_stopwatch = 1
let s:spc = g:airline_symbols.space
let s:rsp = (g:airline_right_alt_sep == '') ? ('|') : (g:airline_right_alt_sep)

if !exists('g:airline#extensions#stopwatch#polling_period')
  let g:airline#extensions#stopwatch#polling_period = 50
endif

function! airline#extensions#stopwatch#init(ext)
  call airline#extensions#stopwatch#reset()
  call airline#parts#define_raw('stopwatch', '%{airline#extensions#stopwatch#get()}')
  call a:ext.add_statusline_func('airline#extensions#stopwatch#apply')
endfunction

function! airline#extensions#stopwatch#apply(...)
  let w:airline_section_z = get(w:, 'airline_section_z', g:airline_section_z)
  let w:airline_section_z .= s:spc . s:rsp
  let w:airline_section_z .= s:spc . '%{airline#extensions#stopwatch#get()}'
endfunction

function! s:get_elapsed_time()
  return s:saved_time + reltimefloat(reltime(s:start_time))
endfunction

function! s:time_to_string(time)
  return printf("%.2f", a:time)
endfunction

function! s:list_to_string(list, separator)
  let ans = ""
  for item in a:list
    let ans = (ans == "") ? item : (ans . a:separator . item)
  endfor
  return ans
endfunction

function! airline#extensions#stopwatch#get()
  if s:running
    let s:elapsed_time = s:get_elapsed_time()
  endif
  let ans = s:list_to_string(s:time_list, s:spc . s:rsp . s:spc)
  if ans != ""
    return ans . s:spc . s:rsp . s:spc . s:time_to_string(s:elapsed_time)
  else
    return s:time_to_string(s:elapsed_time)
  endif
endfunction

function! airline#extensions#stopwatch#update(timer)
  call airline#update_statusline()
endfunction

" timer is used to refresh status line, not for time tracking
function! s:new_timer()
  return timer_start(
          \ g:airline#extensions#stopwatch#polling_period,
          \ "airline#extensions#stopwatch#update", {'repeat' : -1})
endfunction

function! airline#extensions#stopwatch#run()
  if s:running == 0
    let s:start_time = reltime()
    let s:timer = s:new_timer()
    let s:running = 1
  endif
endfunction

function! airline#extensions#stopwatch#split()
  if s:running == 1
    let s:time_list = s:time_list + [s:time_to_string(s:get_elapsed_time())]
    echom s:list_to_string(s:time_list, '|')
  endif
endfunction

function! airline#extensions#stopwatch#stop()
  if s:running == 1
    let s:saved_time = s:elapsed_time
    let s:time_list = s:time_list + [s:time_to_string(s:saved_time)]
    echom s:list_to_string(s:time_list, '|')
    let s:running = 0
  endif
  if exists("s:timer")
    call timer_stop(s:timer)
  endif
endfunction

function! airline#extensions#stopwatch#reset()
  let s:elapsed_time = 0
  let s:saved_time = 0
  let s:start_time = reltime()
  let s:time_list = []
  let s:running = 0
  if exists("s:timer")
    call timer_stop(s:timer)
  endif
endfunction
