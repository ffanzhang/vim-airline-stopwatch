scriptencoding utf-8

if v:version < 800
  echoerr "stopwatch: requires vim 8.0+"
  finish
endif

if !has('timers')
  echoerr "stopwatch: requires vim with +timers feature"
  finish
endif

if !has('reltime')
  echoerr "stopwatch: requires vim with +reltime feature"
  finish
endif

if exists('g:loaded_vim_airline_stopwatch')
  " already loaded
  finish
endif

" default values
if !exists('g:airline#extensions#stopwatch#polling_period')
  let g:airline#extensions#stopwatch#polling_period = 50
endif

if !exists('g:airline#extensions#stopwatch#max_extra_items')
  let g:airline#extensions#stopwatch#max_extra_items = -1
endif

if !exists('g:airline#extensions#stopwatch#save_to_messages')
  let g:airline#extensions#stopwatch#save_to_messages = 1
endif

let g:loaded_vim_airline_stopwatch = 1
let s:spc = g:airline_symbols.space
let s:rsp = (g:airline_right_alt_sep == '') ? ('|') : (g:airline_right_alt_sep)
let s:elapsed_time = 0
let s:saved_time = 0
let s:start_time = reltime()
let s:running = 0

let s:enum_split = 0
let s:enum_stop = 1
let s:events = [[], []]

function! s:get_elapsed_time()
  return s:saved_time + reltimefloat(reltime(s:start_time))
endfunction

function! s:time_to_string(time)
  let time_units = float2nr(a:time)
  let millis = float2nr(round((a:time) * 100.0)) % 100
  let time_string = ''
  " time_level of 0 means sec, 1 means min, 2 means hr
  for time_level in [0, 1, 2]
    if time_units == 0
      break
    endif
    let cur_time = (time_level < 2) ? (time_units % 60) : time_units
    let time_string = (time_string == '') ? printf('%02d', cur_time) : (printf('%02d', cur_time) . ':' . time_string)
    let time_units /= 60
  endfor
  let time_string = (time_string == '') ? (printf('0.%02d', millis)) : time_string . printf('.%02d', millis)
  return time_string
endfunction

function! s:list_join(list, separator)
  let ans = ''
  for item in a:list
    let ans = (ans == '') ? s:time_to_string(item) : (ans . a:separator . s:time_to_string(item))
  endfor
  return ans
endfunction

" get at most n last items
function! s:get_last_n(list, n)
  if len(a:list) < a:n
    return a:list
  elseif a:n == 0
    return []
  else
    return a:list[-a:n:]
  endif
endfunction

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

function! airline#extensions#stopwatch#get()
  if s:running
    let s:elapsed_time = s:get_elapsed_time()
  endif
  let num_items = g:airline#extensions#stopwatch#max_extra_items
  if num_items == -1
    let ans = s:list_join(s:events[s:enum_split], s:spc . s:rsp . s:spc)
  else
    let ans = s:list_join(s:get_last_n(s:events[s:enum_split], num_items), s:spc . s:rsp . s:spc)
  endif
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
    call add(s:events[s:enum_split], s:get_elapsed_time())
    if g:airline#extensions#stopwatch#save_to_messages
      echom s:list_join(s:events[s:enum_split], '|')
    endif
  endif
endfunction

function! airline#extensions#stopwatch#stop()
  if s:running == 1
    let s:saved_time = s:elapsed_time
    call add(s:events[s:enum_stop], s:elapsed_time)
    let s:running = 0
  endif
  if exists('s:timer')
    call timer_stop(s:timer)
  endif
endfunction

function! airline#extensions#stopwatch#reset()
  let s:elapsed_time = 0
  let s:saved_time = 0
  let s:start_time = reltime()
  let s:running = 0
  let s:events = [[], []]
  if exists('s:timer')
    call timer_stop(s:timer)
  endif
endfunction

function! airline#extensions#stopwatch#summary()
  if s:events == [[], []]
    echoerr "No Data, No Summary"
    return
  endif

  execute("sp stopwatch_summary_" . reltimestr(reltime()))
  if len(s:events[s:enum_split]) > 0
    call append(line('$'), printf('%-12s, %s', 'Split Time', 'Duration'))
    let splitlist = s:events[s:enum_split]
    let i = 0
    while i < len(splitlist)
      call append(line('$'),
            \ printf('%-12s, %s',
            \ s:time_to_string(splitlist[i]),
            \ (i == 0) ?
            \ s:time_to_string(splitlist[i]) :
            \ s:time_to_string(splitlist[i] - splitlist[i-1])))
      let i += 1
    endwhile
  endif

  " times that we stopped
  if len(s:events[s:enum_stop]) > 0
    call append(line('$'), '')
    call append(line('$'), 'Stop Time')
    call append(line('$'), map(copy(s:events[s:enum_stop]), 's:time_to_string(v:val)'))
  endif
endfunction

" testing is only enabled is g:airline_stopwatch_runtests is set
if exists('g:airline_stopwatch_runtests') && g:airline_stopwatch_runtests
  " test time to string
  call assert_equal("0.00",           s:time_to_string(0.0000))
  call assert_equal("0.01",           s:time_to_string(0.0100))
  call assert_equal("0.28",           s:time_to_string(0.2800))
  call assert_equal("05.00",          s:time_to_string(5.0000))
  call assert_equal("05.34",          s:time_to_string(5.3400))
  call assert_equal("45.34",          s:time_to_string(45.3400))
  call assert_equal("01:00.00",       s:time_to_string(60.0000))
  call assert_equal("01:05.34",       s:time_to_string(65.3400))
  call assert_equal("01:15.34",       s:time_to_string(75.3400))
  call assert_equal("01:00:00.00",    s:time_to_string(3600.0000))
  call assert_equal("60:00:00.00",    s:time_to_string(216000.0000))
  call assert_equal("100:00:00.00",   s:time_to_string(360000.0000))
  call assert_equal("200:57:02.12",   s:time_to_string(723422.1234))

  " test list to string
  call assert_equal("",                     s:list_join([], '|'))
  call assert_equal("03.14",                s:list_join([3.1400], '|'))
  call assert_equal("03.14|04.28",          s:list_join([3.1400, 4.2800], '|'))
  call assert_equal("03.14|04.28|01:15.28", s:list_join([3.1400, 4.2800, 75.2800], '|'))

  if len(v:errors) == 0
    echom "stopwatch: all tests have passed"
  else
    echom "stopwatch: some tests have failed"
    for i in v:errors
      echom i
    endfor
  endif
endif
