scriptencoding utf-8

if !has("timers")
  echoerr "stopwatch: requires vim to be compiled with +timers feature"
  finish
endif

if !has("reltime")
  echoerr "stopwatch: requires vim to be compiled with +reltime feature"
  finish
endif

if exists('g:loaded_vim_airline_stopwatch')
  finish
endif

let g:loaded_vim_airline_stopwatch = 1
let s:spc = g:airline_symbols.space

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
  if g:airline_right_alt_sep != ''
    let w:airline_section_z .= s:spc.g:airline_right_alt_sep
  endif
  let w:airline_section_z .= s:spc.'%{airline#extensions#stopwatch#get()}'
endfunction

function! airline#extensions#stopwatch#get()
  if g:airline#extensions#stopwatch#running
    let g:airline#extensions#stopwatch#elapsed_time =
                \ g:airline#extensions#stopwatch#saved_time +
                \ reltimefloat(reltime(g:airline#extensions#stopwatch#start_time))
  endif
  return printf("%.2f", g:airline#extensions#stopwatch#elapsed_time)
endfunction

function! airline#extensions#stopwatch#update(timer)
  call airline#update_statusline()
endfunction

" timer is used to refresh status line, not for time tracking
function! airline#extensions#stopwatch#new_timer()
  return timer_start(
          \ g:airline#extensions#stopwatch#polling_period,
          \ 'airline#extensions#stopwatch#update',{'repeat':-1})
endfunction

function! airline#extensions#stopwatch#run()
  if g:airline#extensions#stopwatch#running == 0
    let g:airline#extensions#stopwatch#start_time = reltime()
    let g:airline#extensions#stopwatch#running = 1
    let g:airline#extensions#stopwatch#timer = airline#extensions#stopwatch#new_timer()
  endif
endfunction

function! airline#extensions#stopwatch#split()
  echom airline#extensions#stopwatch#get()
endfunction

function! airline#extensions#stopwatch#stop()
  if g:airline#extensions#stopwatch#running == 1
    let g:airline#extensions#stopwatch#running = 0
    let g:airline#extensions#stopwatch#saved_time = g:airline#extensions#stopwatch#elapsed_time
  endif
  if exists("g:airline#extensions#stopwatch#timer")
    call timer_stop(g:airline#extensions#stopwatch#timer)
  endif
endfunction

function! airline#extensions#stopwatch#reset()
  let g:airline#extensions#stopwatch#running = 0
  let g:airline#extensions#stopwatch#elapsed_time = 0
  let g:airline#extensions#stopwatch#saved_time = 0
  let g:airline#extensions#stopwatch#start_time = reltime()
  if exists("g:airline#extensions#stopwatch#timer")
    call timer_stop(g:airline#extensions#stopwatch#timer)
  endif
endfunction
