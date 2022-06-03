+++
title = "Cli Notebook"  # 文章标题
date = 2020-10-17T16:51:54+08:00  # 自动添加日期信息
draft = false  # 设为false可被编译为HTML，true供本地修改
tags = ["shell"]  # 文章标签，可设置多个，用逗号隔开。Hugo会自动生成标签的子URL

+++

# Cli Notebook Shell Script

forked from ihttps://github.com/dcchambers/note-keeper



```bash
#!/bin/bash
# forked from ihttps://github.com/dcchambers/note-keeper
# modify by waytoarcher <waytoarcher@gmail.com> 2020-10-16
YEAR=$(date +'%Y')
MONTH=$(date +'%m')
DAY=$(date +'%d')
NOTE_DIR="$HOME/notes/$category"
NOTE_NAME="$YEAR-$MONTH-$DAY.md"
Author=waytoarcher
Email=waytoarcher@gmail.com

NOTERC="${XDG_CONFIG_HOME:-$HOME/.config}/notekeeper/noterc"
# shellcheck source=/dev/null
if [ -f "$NOTERC" ]; then . "$NOTERC"; fi

menu() {
	pushd "$HOME/notes" &>/dev/null || exit
	printf "# My Wiki\n\n" >"$HOME"/notes/README.md
	for dir in $(ls -l . | grep "^d" | awk '{print $9}'); do
		echo -e "[$dir]($dir/index.md)\n" >>"$HOME"/notes/README.md
		rm -rf "$dir"/index.md
		echo -e "[Parent](../README.md)\n\n# $dir\n" >"$dir"/index.md
		pushd "$dir" &>/dev/null || exit
		#	for x in $(ls -I index.md $dir);do echo -e "[${x%%.*}](./$x)\n" >> "$dir"/index.md; done
		for x in ./*; do
			y="${x%%.md*}"
			[[ $y == "./index" ]] && continue
			echo -e "[${y/.\//}]($x)\n" >> ./index.md
		done
		popd &>/dev/null || exit
	done
	popd &>/dev/null || exit
}

add_note() {
	NOTE_DIR="$HOME/notes/$category"
	if [ ! -f "$NOTE_DIR/$NOTE_NAME" ]; then
		mkdir -p "$NOTE_DIR"
		touch "$NOTE_DIR/$NOTE_NAME"
		cat <<EOF | tee "$NOTE_DIR/$NOTE_NAME"

[index](./index.md)

# $(echo "${NOTE_NAME%%.*}" | awk -F "-" '{print $4}') 

---

Author:$Author 

Email :$Email

Date  :$(date +%F)

tags  : 

---


EOF
		printf "Created new note: %s/%s\n" "$NOTE_DIR" "$NOTE_NAME"
		menu
	fi
}

print_info() {
	if [ -z "$category" ]; then category=default; fi
	NOTE_DIR="$HOME/notes/$category"
	printf "Note preview:\n====================\n\n"
	head -n 8 "$NOTE_DIR/$NOTE_NAME"
	printf "\n====================\n"
	printf "Note Stats:\n"
	stat "$NOTE_DIR/$NOTE_NAME"
	printf "\n====================\n"
	printf "File Information:\n"
	ls -lah "$NOTE_DIR/$NOTE_NAME"
}

print_help() {
	echo -e "note - Note Keeper 0.5.0 (28 July 2020)

Usage: note [arguments]

Arguments:
  -h | --help                         Display usage guide.

  -c | --category                     Set category for note.
  -n | --name                         Set filename for note. Will be created in \$NOTE_DIR

  -e | --edit <DATE: year-month-day>  Open a specific note for editing.
  -p | --print                        Print the contents of a note.
  -a | --add                          Create a note but don't open it for editing.

  -i | --info                         Print information about a note.
  -t | --time                         Add a timestamp when opening a note.
  -m | --menu                         Update README and $category/index.md

The script loads configuration variables from \${XDG_CONFIG_HOME:-\$HOME/.config}/notekeeper/noterc.

Example:
# Directory where the current note should be stored
NOTE_DIR=\"\$HOME/notes/\$category\"

# Name of the Note
NOTE_NAME=\"\$YEAR-$MONTH-$DAY.md\"\n"
}

open_note() {
	if [ -z "$category" ]; then category=default; fi
	NOTE_DIR="$HOME/notes/$category"
	if ! [ -f "$NOTE_DIR/$NOTE_NAME" ]; then printf "Note %s/%s doesn't exist.\n" "$NOTE_DIR" "$NOTE_NAME" && exit 1; fi
	if [[ $EDITOR = *"vim"* ]] || [[ $EDITOR = *"nvim"* ]]; then
		# Open Vim or Neovim in insert mode.
		$EDITOR "+normal G$" "$NOTE_DIR/$NOTE_NAME"
	elif [[ $EDITOR = *"emacs"* ]]; then
		# Open Emacs with cursor at EOF.
		emacs -nw "$NOTE_DIR/$NOTE_NAME" --eval "(goto-char (point-max))"
	elif [[ $EDITOR = "" ]]; then
		# If no default editor, use Vim and open in insert mode.
		vim "+normal G$" "$NOTE_DIR/$NOTE_NAME"
	else
		$EDITOR "$NOTE_DIR/$NOTE_NAME"
	fi
}

if (($# > 0)); then
	while [[ $# -gt 0 ]]; do
		key="$1"
		case $key in
		-e | --edit)
			printf "(e)dit is not yet implemented :(\n"
			exit 0
			;;
		-p | --print)
			cat "$NOTE_DIR/$NOTE_NAME"
			shift
			;;
		-a | --add)
			if [ -z "$category" ]; then category=default; fi
			add_note
			shift
			;;
		-i | --info)
			print_info
			shift
			;;
		-c | --category)
			category="$2"
			if [ -z "$category" ]; then category=default; fi
			shift
			shift
			if [ "$#" == 0 ]; then open_note; fi
			;;
		-n | --name)
			NOTE_NAME="$YEAR-$MONTH-$DAY-$2.md"
			if [ -z "$NOTE_NAME" ]; then printf "No name found. Please provide a name.\n" && exit 1; fi
			if [ -z "$category" ]; then category=default; fi
			# Hacky way of checking if -n is the only option
			if [ "$#" -eq 2 ]; then
				shift
				shift
				add_note
				open_note
			fi
			shift
			shift
			;;
		-h | --help)
			print_help
			shift
			;;
		-t | --time)
			if [ -z "$category" ]; then printf "No category name found. Please provide a category name.\n" && exit 1; fi
			printf "%s\n" "[$(date +%T)]" >>"$NOTE_DIR/$NOTE_NAME"
			shift
			open_note
			;;
		-m | --menu)
			menu
			shift
			;;
		*)
			printf "Unknown Argument %s \n" "$1"
			printf "Try \"note --help\" to see usage information.\n"
			shift
			;;
		esac
	done
else
	open_note
fi
```

