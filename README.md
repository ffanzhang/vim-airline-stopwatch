# vim-airline-stopwatch
- a vim-airline extension that implements a stopwatch

# Requirements
- vim 8.0
- vim-airline plugin
- vim compiled with the following features, this means when you type
    vim --version, the following features will show up
    - +reltime
    - +timers

# Installation
| Plugin Manager | Install with... |
| ------------- | ------------- |
| [Pathogen] | `git clone https://github.com/ffanzhang/vim-airline-stopwatch ~/.vim/bundle/vim-airline-stopwatch`|
| [Vundle] | `Plugin 'ffanzhang/vim-airline-stopwatch'` , then :source %, :PluginInstall in vim|
| [Plug] | `Plug 'ffanzhang/vim-airline-stopwatch'`, then :source %, :PlugInstall in vim|
- for Pathogen and zipped version, we can also place everything under ~/.vim/bundle, so
  the directory will look like ~/.vim/bundle/vim-airline-stopwatch/..

# Usage
- also see the Customization section to setup mappings
```
:call airline#extensions#stopwatch#run()<CR>
:call airline#extensions#stopwatch#split()<CR>
:call airline#extensions#stopwatch#stop()<CR>
:call airline#extensions#stopwatch#reset()<CR>
```

## Viewing time splits
- each time split will create an entry on the statusline. If there are
too many splits that overflow the statusline, use the type :messges to view
the splits. Note the final stop time is not included in messages. The
rationale is stop() is actually pause() in disguise :)
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
- setting up shortcut keys so that we don't have to manually type the
calls every time.
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
```

# Caveats
- Since this plugin is updating the statusline pretty frequently, expect heavy
  CPU usage. One thing we can do to decrease this percentage is to slow down
  polling by increasing g:airline#extensions#stopwatch#polling_period.
- This plugin is only designed to time things within a few minutes, we might
  expect memory leak if running for a prolonged period of time.

