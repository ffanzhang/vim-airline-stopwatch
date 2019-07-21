# vim-airline-stopwatch
- a vim-airline extension that implements a stopwatch

# Requirements
- vim
- vim-airline plugin
- vim compiled with the following features, this means when you type
    vim --version, the following features will show up
    - +reltime
    - +timers

# Installation
| Plugin Manager | Install with... |
| ------------- | ------------- |
| [Pathogen] | `git clone https://github.com/ffanzhang/vim-airline-stopwatch ~/.vim/bundle/vim-airline-stopwatch`|
| [Vundle] | `Plugin 'ffanzhang/vim-airline-stopwatch'` |
| manual | copy all of the files into your `~/.vim` directory |

# Usage
```
:call airline#extensions#stopwatch#run()<CR>
:call airline#extensions#stopwatch#split()<CR>
:call airline#extensions#stopwatch#stop()<CR>
:call airline#extensions#stopwatch#reset()<CR>
```
## viewing splits
```
:messages
```

# Customization
## To be placed in your .vimrc
- (optional) polling_period controls the amount of time between
each status line update, the bigger the number the slower it is.
The default number is 50ms. example:
```
let g:airline#extensions#stopwatch#polling_period = 50
```
```
map VIM_KEY_SEQUENCE :call airline#extensions#stopwatch#run()<CR>
map VIM_KEY_SEQUENCE :call airline#extensions#stopwatch#split()<CR>
map VIM_KEY_SEQUENCE :call airline#extensions#stopwatch#stop()<CR>
map VIM_KEY_SEQUENCE :call airline#extensions#stopwatch#reset()<CR>
```
- example 1:
```
map <F4> :call airline#extensions#stopwatch#run()<CR>
map <F5> :call airline#extensions#stopwatch#split()<CR>
map <F6> :call airline#extensions#stopwatch#stop()<CR>
map <F7> :call airline#extensions#stopwatch#reset()<CR>
```
- example 2:

```
map tr :call airline#extensions#stopwatch#run()<CR>
map tp :call airline#extensions#stopwatch#split()<CR>
map ts :call airline#extensions#stopwatch#stop()<CR>
map tt :call airline#extensions#stopwatch#reset()<CR>
