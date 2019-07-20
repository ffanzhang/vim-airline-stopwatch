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
  call airline#parts#define_raw('stopwatch', '%{airline#extensions#stopwatch#get()}')
  let g:airline#extensions#stopwatch#ext = a:ext
  call a:ext.add_statusline_func('airline#extensions#stopwatch#apply')
endfunction

function! airline#extensions#stopwatch#apply(...)
  let w:airline_section_c = get(w:, 'airline_section_c', g:airline_section_c)
  if g:airline_right_alt_sep != ''
    let w:airline_section_c .= s:spc.g:airline_right_alt_sep
  endif
  let w:airline_section_c .= s:spc.'%{airline#extensions#stopwatch#get()}'
  let w:airline_section_c .= s:spc.g:airline_left_alt_sep
endfunction

let g:airline#extensions#stopwatch#start_time = reltime()
let g:airline#extensions#stopwatch#running = 0
let g:airline#extensions#stopwatch#saved_time = 0
let g:airline#extensions#stopwatch#elapsed_time = 0

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

function! airline#extensions#stopwatch#new_timer()
  return timer_start(
          \ g:airline#extensions#stopwatch#polling_period,
          \ 'airline#extensions#stopwatch#update',{'repeat':-1})
endfunction

let g:airline#extensions#stopwatch#timer = airline#extensions#stopwatch#new_timer()

function! airline#extensions#stopwatch#run()
  if g:airline#extensions#stopwatch#running == 0
    let g:airline#extensions#stopwatch#start_time = reltime()
    let g:airline#extensions#stopwatch#running = 1
  endif
endfunction

function! airline#extensions#stopwatch#stop()
  if g:airline#extensions#stopwatch#running == 1
    let g:airline#extensions#stopwatch#running = 0
    let g:airline#extensions#stopwatch#saved_time = g:airline#extensions#stopwatch#elapsed_time
  endif
endfunction

function! airline#extensions#stopwatch#reset()
  let g:airline#extensions#stopwatch#running = 0
  let g:airline#extensions#stopwatch#elapsed_time = 0
  let g:airline#extensions#stopwatch#saved_time = 0
endfunction

map tr :call airline#extensions#stopwatch#run()<CR>
map ts :call airline#extensions#stopwatch#stop()<CR>
map tt :call airline#extensions#stopwatch#reset()<CR>
