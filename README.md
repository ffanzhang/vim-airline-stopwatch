# vim-airline-stopwatch
- a vim-airline extension that implements a stopwatch.

# Requirements
- vim 8.0
- vim-airline plugin
- vim compiled with reltime and timers. This means when you type
    :version while running vim, the following features will show up.
    - +reltime
    - +timers

# Installation
| Plugin Manager | Install with... |
| ------------- | ------------- |
| [Pathogen] | `git clone https://github.com/ffanzhang/vim-airline-stopwatch ~/.vim/bundle/vim-airline-stopwatch`|
| [Vundle] | `Plugin 'ffanzhang/vim-airline-stopwatch'` , then :source %, :PluginInstall |
| [Plug] | `Plug 'ffanzhang/vim-airline-stopwatch'`, then :source %, :PlugInstall |
| [NeoBundle] | `NeoBundle 'ffanzhang/vim-airline-stopwatch'`, then :source %, :NeoBundleInstall |
- for Pathogen and zipped version, we can also place everything under ~/.vim/bundle, so
  the directory will look like ~/.vim/bundle/vim-airline-stopwatch/..

# Usage
- also see the Customization section to setup mappings.
```
:call airline#extensions#stopwatch#run()<CR>
:call airline#extensions#stopwatch#split()<CR>
:call airline#extensions#stopwatch#stop()<CR>
:call airline#extensions#stopwatch#reset()<CR>
:call airline#extensions#stopwatch#summary()<CR>
```

## Viewing time splits
- each call to split will create an entry on the status line. If there are
too many splits, this plugin will overflow the status line. Type :messges in vim to view
the splits. Note that the final stop time is not included in messages. The
rationale is stop() is actually pause() in disguise :) Also note you can
disable messages by setting let g:airline#extensions#stopwatch#save_to_messages = 0

```
:messages
```
- for v0.1.0 and after, we have a more comprehensive summary of split times and
  stop times opened in a new buffer.
```
:call airline#extensions#stopwatch#summary()<CR>
```

# Customization
## To be placed in your .vimrc or appropriate files for your vim configuration
- (optional) polling_period controls the amount of time between
each status line update, the bigger the number the slower it is.
The default number is 50ms. If we want to make it bigger, we can set it to
100ms for example.
```
let g:airline#extensions#stopwatch#polling_period = 100
```
- (optional) if we have too many split items, saving to :messages
 will allow vim to disrupt us by prompting "press ENTER or type command to continue", to disable this
 default behavior, we can set save_to messages = 0. This also means that if you
 set this to 0, :messages no longer provides splits. But we can still view past
 splits using the summary() feature.
```
let g:airline#extensions#stopwatch#save_to_messages = 0
```
- (optional) also if we have too many split items, it's sometimes desirable to
    limit the max number of extra items on the status line.
    - -1 means no limit
    - 0 means just the timer itself.
```
let g:airline#extensions#stopwatch#max_extra_items = 5
```

- setting up shortcut keys so that we don't have to manually type the
calls every time.
```
map VIM_KEY_SEQUENCE :call airline#extensions#stopwatch#run()<CR>
map VIM_KEY_SEQUENCE :call airline#extensions#stopwatch#split()<CR>
map VIM_KEY_SEQUENCE :call airline#extensions#stopwatch#stop()<CR>
map VIM_KEY_SEQUENCE :call airline#extensions#stopwatch#reset()<CR>
map VIM_KEY_SEQUENCE :call airline#extensions#stopwatch#summary()<CR>
```
- example 1:
```
map <F4> :call airline#extensions#stopwatch#run()<CR>
map <F5> :call airline#extensions#stopwatch#split()<CR>
map <F6> :call airline#extensions#stopwatch#stop()<CR>
map <F7> :call airline#extensions#stopwatch#reset()<CR>
map <F8> :call airline#extensions#stopwatch#summary()<CR>
```
- example 2:

```
map tr :call airline#extensions#stopwatch#run()<CR>
map tp :call airline#extensions#stopwatch#split()<CR>
map ts :call airline#extensions#stopwatch#stop()<CR>
map tt :call airline#extensions#stopwatch#reset()<CR>
map ty :call airline#extensions#stopwatch#summary()<CR>
```

# Caveats
- since this plugin is updating the status line pretty frequently, expect heavy
  CPU usage. One thing we can do to decrease this usage is to slow down
  polling by increasing g:airline#extensions#stopwatch#polling_period.
- this plugin is only designed to time things within a few minutes, we might
  expect memory leak if running for a prolonged period of time.
