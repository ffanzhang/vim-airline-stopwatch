scriptencoding utf-8

if v:version < 800
  echoerr 'vim-airline-stopwatch: requires vim 8.0+'
  finish
endif

if !has('timers')
  echoerr 'vim-airline-stopwatch: requires vim with +timers feature'
  finish
endif

if !has('reltime')
  echoerr 'vim-airline-stopwatch: requires vim with +reltime feature'
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

" symbol related variables
let s:spc = g:airline_symbols.space
let s:rsp = (g:airline_right_alt_sep == '') ? ('|') : (g:airline_right_alt_sep)

" script critical variables
let s:elapsed_time = 0
let s:saved_time = 0
let s:start_time = reltime()
let s:running = 0

let s:enum_split = 0
let s:enum_stop = 1
let s:events = [[], []]

function! s:map(l, fn)
  let new_list = deepcopy(a:l)
  call map(new_list, string(a:fn) . '(v:val)')
  return new_list
endfunction

function! s:get_elapsed_time()
  return s:saved_time + reltimefloat(reltime(s:start_time))
endfunction

" get at most n last items
function! s:get_last_n(list, n)
  if a:n <= 0
    return []
  elseif len(a:list) < a:n
    return a:list
  else
    return a:list[-a:n:]
  endif
endfunction

" yep this is hard to read
" - round floating point seconds and save what's after the decimal point.
" - grab the remainder (seconds) of dividing by 60 and do some weird formatting,
"       then divide by 60, prepend to time list
" - grab the remainder (minutes) of dividing by 60 and do some weird formatting,
"       then divide by 60, prepend to time list
" - whatever's left is the hour, prepend to time list
" - convert list to string
" - append decimal points
function! s:time_to_string(time)
  let time_units = float2nr(a:time)
  let millis = float2nr(round((a:time) * 100.0)) % 100
  let time_string = ''
  " time_level of 0 means sec, 1 means min, 2 means hr
  let time_list = []
  for time_level in [0, 1, 2]
    if time_units == 0
      break
    endif
    let cur_time = (time_level < 2) ? (time_units % 60) : time_units
    let time_units = time_units / 60
    call insert(time_list, printf('%02d', cur_time))
  endfor
  let time_string = join(time_list, ':')
  return (time_string == '') ? (printf('0.%02d', millis)) : time_string . printf('.%02d', millis)
endfunction

" timer is used to refresh status line, not for time tracking
function! s:new_timer()
  return timer_start(
        \ g:airline#extensions#stopwatch#polling_period,
        \ 'airline#extensions#stopwatch#update', {'repeat' : -1})
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
  if g:airline#extensions#stopwatch#max_extra_items == -1
    let ans = join(s:map(s:events[s:enum_split], function('s:time_to_string')), s:spc . s:rsp . s:spc)
  else
    let ans = join(s:map(s:get_last_n(s:events[s:enum_split], g:airline#extensions#stopwatch#max_extra_items), function('s:time_to_string')), s:spc . s:rsp . s:spc)
  endif
  return (ans == '') ? (s:time_to_string(s:elapsed_time)) : (ans . s:spc . s:rsp . s:spc . s:time_to_string(s:elapsed_time))
endfunction

function! airline#extensions#stopwatch#update(timer)
  call airline#update_statusline()
endfunction

function! airline#extensions#stopwatch#run()
  if !s:running
    let s:start_time = reltime()
    let s:timer = s:new_timer()
    let s:running = 1
  endif
endfunction

function! airline#extensions#stopwatch#split()
  if s:running
    call add(s:events[s:enum_split], s:get_elapsed_time())
    if g:airline#extensions#stopwatch#save_to_messages
      echom join(s:map(s:events[s:enum_split], function('s:time_to_string')), '|')
    endif
  endif
endfunction

function! airline#extensions#stopwatch#stop()
  if s:running
    let s:elapsed_time = s:get_elapsed_time()
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
    echoerr 'vim-airline-stopwatch: no data, no summary'
    return
  endif

  execute('sp stopwatch_summary_' . reltimestr(reltime()))
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

"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" testing section
"
" python is only required for testing
" vim's builtin sleep behaves unpredictably
function! s:python_tests(py_interp)
  if a:py_interp == 'None'
    return
  endif

execute a:py_interp '<< F00D1E'
import vim
import time
from datetime import datetime, timedelta

# assume a fast computer, some tests might fail if time difference is >= 0.02s
try:
  # simulates a basic use of stopwatch
  vim.command('call airline#extensions#stopwatch#run()')
  time.sleep(1.23)
  vim.command('call airline#extensions#stopwatch#stop()')
  vim.command('call assert_true(abs(s:elapsed_time - 1.23) < 0.02)')
  vim.command('call assert_true(abs(s:saved_time - 1.23) < 0.02)')
  vim.command('call assert_equal(len(s:events[s:enum_stop]), 1)')
  vim.command('call assert_equal(len(s:events[s:enum_split]), 0)')

  # waiting does not increment elapsed_time
  time.sleep(1)
  vim.command('call assert_true(abs(s:elapsed_time - 1.23) < 0.02)')
  vim.command('call assert_true(abs(s:saved_time - 1.23) < 0.02)')

  # continue running the stopwatch, should not account the 1 second pause time
  vim.command('call airline#extensions#stopwatch#run()')
  time.sleep(2.15)
  vim.command('call airline#extensions#stopwatch#stop()')
  vim.command('call assert_true(abs(s:elapsed_time - 3.38) < 0.02)')
  vim.command('call assert_true(abs(s:saved_time - 3.38) < 0.02)')
  time.sleep(0.5)

  # splitting
  vim.command('call airline#extensions#stopwatch#run()')
  time.sleep(2.0)
  vim.command('call airline#extensions#stopwatch#split()')
  vim.command('call assert_equal(len(s:events[s:enum_split]), 1)')
  vim.command('call assert_true(abs(s:events[s:enum_split][0] - 5.38) < 0.02)')
  time.sleep(2.2)
  vim.command('call airline#extensions#stopwatch#split()')
  vim.command('call assert_equal(len(s:events[s:enum_split]), 2)')
  vim.command('call assert_true(abs(s:events[s:enum_split][1] - 7.58) < 0.02)')

  # resetting
  vim.command('call airline#extensions#stopwatch#reset()')
  vim.command('call assert_equal(len(s:events[s:enum_stop]), 0)')
  vim.command('call assert_equal(len(s:events[s:enum_split]), 0)')
  vim.command('call assert_equal(s:saved_time, 0)')
  vim.command('call assert_equal(s:elapsed_time, 0)')
  vim.command('call assert_equal(s:running, 0)')

  # clean up properly from running to resetting
  vim.command('call airline#extensions#stopwatch#run()')
  time.sleep(0.23)
  vim.command('call airline#extensions#stopwatch#reset()')
  vim.command('call assert_equal(len(s:events[s:enum_stop]), 0)')
  vim.command('call assert_equal(len(s:events[s:enum_split]), 0)')
  vim.command('call assert_equal(s:saved_time, 0)')
  vim.command('call assert_equal(s:elapsed_time, 0)')
  vim.command('call assert_equal(s:running, 0)')

  # clean up properly from stopping to resetting
  vim.command('call airline#extensions#stopwatch#run()')
  time.sleep(0.13)
  vim.command('call airline#extensions#stopwatch#stop()')
  vim.command('call airline#extensions#stopwatch#reset()')
  vim.command('call assert_equal(len(s:events[s:enum_stop]), 0)')
  vim.command('call assert_equal(len(s:events[s:enum_split]), 0)')
  vim.command('call assert_equal(s:saved_time, 0)')
  vim.command('call assert_equal(s:elapsed_time, 0)')
  vim.command('call assert_equal(s:running, 0)')

  # should not allow split while stopping
  vim.command('call airline#extensions#stopwatch#run()')
  time.sleep(0.13)
  vim.command('call airline#extensions#stopwatch#stop()')
  vim.command('call airline#extensions#stopwatch#split()')
  vim.command('call assert_equal(len(s:events[s:enum_split]), 0)')
  vim.command('call airline#extensions#stopwatch#reset()')

  # calling run after run should not change stopwatch state
  vim.command('call airline#extensions#stopwatch#run()')
  time.sleep(0.13)
  vim.command('call airline#extensions#stopwatch#run()')
  time.sleep(0.13)
  vim.command('call airline#extensions#stopwatch#stop()')
  vim.command('call assert_true(abs(s:elapsed_time - 0.26) < 0.02)')
  vim.command('call airline#extensions#stopwatch#reset()')

  # calling stop after stop should not have change stopwatch state
  vim.command('call airline#extensions#stopwatch#run()')
  time.sleep(0.13)
  vim.command('call airline#extensions#stopwatch#stop()')
  time.sleep(0.13)
  vim.command('call airline#extensions#stopwatch#stop()')
  vim.command('call assert_true(abs(s:elapsed_time - 0.13) < 0.02)')
except Exception as e:
  print(e)

F00D1E
endfunction

" testing helper
function! s:array_equal(a, b)
  if len(a:a) != len(a:b)
    return 0
  endif
  let i = 0
  while i < len(a:a)
    if get(a:a, i) != get(a:b, i)
      return 0
    endif
    let i += 1
  endwhile
  return 1
endfunction

" testing is only enabled is g:airline_stopwatch_runtests is set
if exists('g:airline_stopwatch_runtests') && g:airline_stopwatch_runtests
  " test time to string
  call assert_equal('0.00',           s:time_to_string(0.0000))
  call assert_equal('0.01',           s:time_to_string(0.0100))
  call assert_equal('0.28',           s:time_to_string(0.2800))
  call assert_equal('05.00',          s:time_to_string(5.0000))
  call assert_equal('05.34',          s:time_to_string(5.3400))
  call assert_equal('45.34',          s:time_to_string(45.3400))
  call assert_equal('01:00.00',       s:time_to_string(60.0000))
  call assert_equal('01:05.34',       s:time_to_string(65.3400))
  call assert_equal('01:15.34',       s:time_to_string(75.3400))
  call assert_equal('01:00:00.00',    s:time_to_string(3600.0000))
  call assert_equal('60:00:00.00',    s:time_to_string(216000.0000))
  call assert_equal('100:00:00.00',   s:time_to_string(360000.0000))
  call assert_equal('200:57:02.12',   s:time_to_string(723422.1234))

  " test get last n
  call assert_true(s:array_equal(s:get_last_n([], 0),           []))
  call assert_true(s:array_equal(s:get_last_n([1, 3, 5], 0),    []))
  call assert_true(s:array_equal(s:get_last_n([1, 3, 5], -1),   []))
  call assert_true(s:array_equal(s:get_last_n([1, 3, 5], 2),    [3, 5]))
  call assert_true(s:array_equal(s:get_last_n([1, 3, 5], 3),    [1, 3, 5]))
  call assert_true(s:array_equal(s:get_last_n([1, 3, 5], 8),    [1, 3, 5]))

  " python is only required for testing
  let s:python_interp = 'None'
  if has('python3')
    let s:python_interp = 'python3'
  elseif has('python')
    let s:python_interp = 'python'
  endif

  call s:python_tests(s:python_interp)

  if len(v:errors) == 0
    echom 'vim-airline-stopwatch: all tests have passed'
  else
    echom 'vim-airline-stopwatch: some tests have failed'
    for i in v:errors
      echom i
    endfor
  endif
endif
