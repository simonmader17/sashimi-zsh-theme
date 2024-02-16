#!/usr/bin/zsh

# Enable colors and activate prompt substitutions
autoload -U colors && colors
setopt prompt_subst

# Set helper variables for colors
cyan="%{$fg[cyan]%}"
yellow="%{$fg[yellow]%}"
red="%{$fg[red]%}"
blue="%{$fg[blue]%}"
green="%{$fg[green]%}"
normal="%{$reset_color%}"

# Sashimi theme
_git_branch_name() {
	git symbolic-ref HEAD 2>/dev/null | sed -e 's|^refs/heads/||'
}
_is_git_dirty() {
	git status -s --ignore-submodules=dirty 2>/dev/null
}
_git_ahead() {
	commits=$(git rev-list --left-right '@{upstream}...HEAD' 2>/dev/null)
	if [ $? != 0 ]; then
		return
	fi
	behind=$(echo $commits | grep "^<" | wc -l)
	ahead=$(echo $commits | grep -v "^<" | wc -l)
	case "$ahead $behind" in
		"") ;; # no upstream
		"0 0") # equal to upstream
			return
			;;
		*\ 0)  # ahead of upstream
			echo -n "%B$blue↑$ahead%b "
			;;
		0\ *)  # behind upstream
			echo -n "%B$red↓$behind%b "
			;;
		*)     # diverged from upstream
			echo -n "%B$blue↑$ahead $red↓$behind%b "
			;;
	esac
}
sashimi() {
	git_branch="$(_git_branch_name)"
	if [ "$git_branch" != "" ]; then
		if [ "$git_branch" = "master" ]; then
			git_info="$normal git:($red%B$git_branch$normal)"
		else
			git_info="$normal git:($blue%B$git_branch$normal)"
		fi

		if [ "$(_is_git_dirty)" != "" ]; then
			dirty="%B$yellow✗%b"
			git_info="$git_info $dirty"
		fi
	fi
	echo -n "%B%(?:$green◆:$red✖ %?) $cyan%c%b$git_info $(_git_ahead)%B%(?:$normal%B❯$cyan❯$green❯:$red❯❯❯)%b$normal "
}

# Set prompt
PROMPT='$(sashimi)'
