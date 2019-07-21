# vim-airline-stopwatch
- a vim-airline extension that implements a stopwatch

# requirements
- vim
- vim-airline plugin
- vim compiled with the following features, this means when you type 
    vim --help, the following features will show up
    - +reltime
    - +timers

# usage
```
:call airline#extensions#stopwatch#run()<CR>
:call airline#extensions#stopwatch#stop()<CR>
:call airline#extensions#stopwatch#reset()<CR>
```

# configurable paramters
## the following paramters can be placed in your .vimrc file.
- (optional) polling_period controls the amount of time between
each status line update, the bigger the number the slower it is.
The default number is 50ms. example:
```
let g:airline#extensions#stopwatch#polling_period = 50
```

## customizing your own keymap
- in your .vimrc, add the following
```
map VIM_KEY_SEQUENCE :call airline#extensions#stopwatch#run()<CR>
map VIM_KEY_SEQUENCE :call airline#extensions#stopwatch#stop()<CR>
map VIM_KEY_SEQUENCE :call airline#extensions#stopwatch#reset()<CR>
```
- example 1:
```
map <F4> :call airline#extensions#stopwatch#run()<CR>
map <F5> :call airline#extensions#stopwatch#stop()<CR>
map <F6> :call airline#extensions#stopwatch#reset()<CR>
```
- example 2:

```
map tr :call airline#extensions#stopwatch#run()<CR>
map ts :call airline#extensions#stopwatch#stop()<CR>
map tt :call airline#extensions#stopwatch#reset()<CR>
