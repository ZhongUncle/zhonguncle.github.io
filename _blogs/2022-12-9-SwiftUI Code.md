---
layout: article
category: SwiftUI
---
这个文件里写着一些命令来改变环境中的变量。
**更改完之后需要重启shell来激活更改。**
```bash
# ~/.bashrc: executed by bash(1) for non-login shells.
# see /usr/share/doc/bash/examples/startup-files (in the package bash-doc) 
# ～/.bashrc: 被未登录到shells通过bash使用。（就是预先设定的环境变量）
# 查看 /usr/share/doc/bash/examples/startup-files (在包bash-doc中)（但是找不到这个文档） 

# for examples 
# 例如（虽然是例如，但是以下命令代码都是正在运行中的，修改之后需要重新启动shell来激活）

# If not running interactively, don't do anything
# 如果没有互动地运行，不做任何事（如果不输入命令，不进行任何操作）
case $- in
    *i*) ;;
      *) return;; 
esac

# don't put duplicate lines or lines starting with space in the history. 
# See bash(1) for more options
# 不把复制的行或以空格开头的行放入历史记录
# 查看bash(1)获取更多信息
HISTCONTROL=ignoreboth

# append to the history file, don't overwrite it
# 添加历史记录文件，不覆盖原来的历史记录文件。
shopt -s histappend

# for setting history length see HISTSIZE and HISTFILESIZE in bash(1)
# 用于设定历史记录的长度。详情请见bash(1)中的HISTSIZE和HISTFILESIZE
HISTSIZE=1000 HISTFILESIZE=2000

# check the window size after each command and, if necessary, update the values of LINES and COLUMNS.
# 在每次命令之后检查窗口尺寸，并且如果有必要的话，更新LINES（行）和COLUMNS（列）的值。
shopt -s checkwinsize

# If set, the pattern "**" used in a pathname expansion context will 
# match all files and zero or more directories and subdirectories.
# 如果设置了，路径名扩展内容中的"**"样式将匹配所有文件和零或更多目录和子目录。
# shopt -s globstar


# make less more friendly for non-text input files, see lesspipe(1)
# 使非文本输入文件更加不友好，请见lesspipe(1)
[ -x /usr/bin/lesspipe ] && eval "$(SHELL=/bin/sh lesspipe)"

# set variable identifying the chroot you work in (used in the prompt below)
# 设置变量，声明你工作的chroot（被使用在标识符下面）
if [ -z "${debian_chroot:-}" ] && [ -r /etc/debian_chroot ]; then 
    debian_chroot=$(cat /etc/debian_chroot)
fi

# set a fancy prompt (non-color, unless we know we "want" color)
# 设置一个多彩的标识符（没有颜色，除非我们知道我们“想要的”颜色）
case "$TERM" in 
    xterm-color|*-256color) color_prompt=yes;; 
esac

# uncomment for a colored prompt, if the terminal has the capability; 
# turned off by default to not distract the user: the focus in a 
# terminal window should be on the output of commands, not on the prompt
# 如果终端有能力，取消一个颜色的注释；（就是取消下面这行命令的注释，将其“激活”）
# 默认关闭，以防其转移用户注意力：聚焦应该在一个命令输出终端窗口，而不是标识符上
#force_color_prompt=yes

if [ -n "$force_color_prompt" ]; then
    if [ -x /usr/bin/tput ] && tput setaf 1 >&/dev/null; then
	# We have color support; assume it's compliant with Ecma-48 
	# (ISO/IEC-6429). (Lack of such support is extremely rare, and 
	# such a case would tend to support setf rather than setaf.)
	# 我们有颜色支持；假设它符合Ecma-48(ISO/IEC-6429)。（缺少这种支持是极其罕见的，并且这样一个case倾向于支持
	# setf，超过setaf。）
         color_prompt=yes 
     else
         color_prompt= 
     fi
fi

if [ "$color_prompt" = yes ]; then
    PS1='${debian_chroot:+($debian_chroot)}\[\033[01;32m\]\u@\h\[\033[00m\]:\[\033[01;34m\]\w\[\033[00m\]\$ '
else
    PS1='${debian_chroot:+($debian_chroot)}\u@\h:\w\$ ' 
fi 
unset color_prompt force_color_prompt

# If this is an xterm set the title to user@host:dir
# 如果这个一个xterm，给user@host:dir设置标题
case "$TERM" in 
xterm*|rxvt*) 
    PS1="\[\e]0;${debian_chroot:+($debian_chroot)}\u@\h: \w\a\]$PS1"
    ;;
*)
    ;;
esac

# enable color support of ls and also add handy aliases
# 激活ls的颜色支持，并且添加好用的同义名
if [ -x /usr/bin/dircolors ]; then 
    test -r ~/.dircolors && eval "$(dircolors -b ~/.dircolors)" || eval "$(dircolors -b)" 
    alias ls='ls --color=auto'
    #alias dir='dir --color=auto' 
    #alias vdir='vdir --color=auto'

    alias grep='grep --color=auto' 
    alias fgrep='fgrep --color=auto' 
    alias egrep='egrep --color=auto'
fi

# colored GCC warnings and errors 
# 有颜色的GCC警告和错误（需要的话取消注释）
# export GCC_COLORS='error=01;31:warning=01;35:note=01;36:caret=01;32:locus=01:quote=01'

# some more ls aliases
# 更多的一些ls的同义名
alias ll='ls -alF' 
alias la='ls -A' 
alias l='ls -CF'

# Add an "alert" alias for long running commands.  Use like so: 
# 添加一个"alert"同义名给长运行命令。使用像这样：
#   sleep 10; alert
alias alert='notify-send --urgency=low -i "$([ $? = 0 ] && echo terminal || echo error)" "$(history|tail -n1|sed -e '\''s/^\s*[0-9]\+\s*//;s/[;&|]\s*alert$//'\'')"'

# Alias definitions. You may want to put all your additions into a separate file like 
# ~/.bash_aliases, instead of adding them here directly.
# See /usr/share/doc/bash-doc/examples in the bash-doc package.
# 同义名定义。你可能想把所有你添加的同义名放到一个单独的文件，像 ~/.bash_aliases，而不是直接全添加在这儿。
# 查看bash-doc包中的/usr/share/doc/bash-doc/examples

if [ -f ~/.bash_aliases ]; then
    . ~/.bash_aliases 
fi

# enable programmable completion features (you don't need to enable 
# this, if it's already enabled in /etc/bash.bashrc and /etc/profile 
# sources /etc/bash.bashrc).
# 激活程序控制完成特性（如果在/etc/bash.bashrc和/etc/profile 
# sources /etc/bash.bashrc已经被激活的话，你就不需要激活这个）
if ! shopt -oq posix; then 
  if [ -f /usr/share/bash-completion/bash_completion ]; then
    . /usr/share/bash-completion/bash_completion 
  elif [ -f /etc/bash_completion ]; then
    . /etc/bash_completion 
  fi 
fi

# Change umask to make directory sharing easier
# 改变umask（权限掩码）来让目录分享更容易。（便于修改文件或目录权限）
umask 0002

# Ignore duplicates in command history and increase history size to 1000 lines
# 在命令历史记录中忽略复制的命令，并且增加历史记录尺寸到1000行
export HISTCONTROL=ignoredups 
export HISTSIZE=1000

# Add some helpful aliases
# 添加一些有用的同义名
alias l.='ls -d .* --color=auto' alias ll='ls -l --color=auto'
 
# expend the PATH argument
# 扩展PATH变量
export PATH=~/bin:"$PATH"



```