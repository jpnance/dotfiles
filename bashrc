SAVE_CURSOR="\[\e[s\]"
CURSOR_TO_TOP="\[\e[H\]"
CURSOR_UP_DOWN="\[\e[1A\e[1B\]"
CLEAR_LINE="\[\e[K\]"
RESTORE_CURSOR="\[\e[u\]"

BOLD="\[\e[1m\]"
NORMAL="\[\e[22m\]"
BLACK_FOREGROUND="\[\e[30m\]"
WHITE_BACKGROUND="\[\e[47m\]"
RESET_COLORS="\[\e[0m\]"

# get current branch in git repo
function parse_git_branch() {
	BRANCH=`git branch 2> /dev/null | sed -e '/^[^*]/d' -e 's/* \(.*\)/\1/'`
	OUTPUT=""

	if [ ! "${BRANCH}" == "" ]
	then
		STAT=`parse_git_dirty`
		OUTPUT="${BRANCH}${STAT}"
	else
		OUTPUT=""
	fi

	echo "$OUTPUT"
}

# get current status of git repo
function parse_git_dirty {
	status=`git status 2>&1 | tee`
	dirty=`echo -n "${status}" 2> /dev/null | grep "modified:" &> /dev/null; echo "$?"`
	untracked=`echo -n "${status}" 2> /dev/null | grep "Untracked files" &> /dev/null; echo "$?"`
	ahead=`echo -n "${status}" 2> /dev/null | grep "Your branch is ahead of" &> /dev/null; echo "$?"`
	newfile=`echo -n "${status}" 2> /dev/null | grep "new file:" &> /dev/null; echo "$?"`
	renamed=`echo -n "${status}" 2> /dev/null | grep "renamed:" &> /dev/null; echo "$?"`
	deleted=`echo -n "${status}" 2> /dev/null | grep "deleted:" &> /dev/null; echo "$?"`
	bits=''
	if [ "${renamed}" == "0" ]; then
		bits=">${bits}"
	fi
	if [ "${ahead}" == "0" ]; then
		bits="*${bits}"
	fi
	if [ "${newfile}" == "0" ]; then
		bits="+${bits}"
	fi
	if [ "${untracked}" == "0" ]; then
		bits="?${bits}"
	fi
	if [ "${deleted}" == "0" ]; then
		bits="x${bits}"
	fi
	if [ "${dirty}" == "0" ]; then
		bits="!${bits}"
	fi
	if [ ! "${bits}" == "" ]; then
		echo "${bits}"
	else
		echo ""
	fi
}

function printTitlebar() {
	echo -e "${SAVE_CURSOR}${CURSOR_TO_TOP}${CLEAR_LINE}${BLACK_FOREGROUND}${WHITE_BACKGROUND}\\w${CLEAR_LINE}${RESET_COLORS}${RESTORE_CURSOR}${CURSOR_UP_DOWN}"
}

function printBar() {
	PREVIOUS_EXIT_CODE=$1
	HOST=$(hostname -s)
	GIT=$(parse_git_branch)

	COLOR_DIRECTORY=33
	COLOR_GIT=99
	COLOR_BAD=196
	COLOR_GOOD=34
	TEXT_COLOR_DIRECTORY=195
	TEXT_COLOR_GIT=225
	TEXT_COLOR_BAD=224
	TEXT_COLOR_GOOD=194
	SEPARATOR_COLOR_DIRECTORY=255
	SEPARATOR_COLOR_GIT=255
	SEPARATOR_COLOR_BAD=255
	SEPARATOR_COLOR_GOOD=255

	COLOR_HOST=234
	COLOR_DIRECTORY=236
	COLOR_GIT=238
	COLOR_BAD=88
	COLOR_GOOD=240
	TEXT_COLOR_HOST=64
	TEXT_COLOR_DIRECTORY=69
	TEXT_COLOR_GIT=176
	TEXT_COLOR_BAD=218
	TEXT_COLOR_GOOD=255
	SEPARATOR_COLOR_HOST=-1
	SEPARATOR_COLOR_DIRECTORY=$((COLOR_DIRECTORY + 1))
	SEPARATOR_COLOR_GIT=$((COLOR_GIT + 1))
	SEPARATOR_COLOR_BAD=124
	SEPARATOR_COLOR_GOOD=$((COLOR_GOOD + 1))

	COLOR_HOST=58
	COLOR_HOST=22
	COLOR_DIRECTORY=18
	COLOR_GIT=53
	COLOR_BAD=124
	COLOR_GOOD=236
	TEXT_COLOR_HOST=142
	TEXT_COLOR_HOST=70
	TEXT_COLOR_DIRECTORY=69
	TEXT_COLOR_GIT=176
	TEXT_COLOR_BAD=224
	TEXT_COLOR_GOOD=250
	SEPARATOR_COLOR_HOST=-1
	SEPARATOR_COLOR_DIRECTORY=-1
	SEPARATOR_COLOR_GIT=-1
	SEPARATOR_COLOR_BAD=-1
	SEPARATOR_COLOR_GOOD=-1

	LATEST_COLOR=$COLOR_HOST

	BAR=""

	#BAR+="\[\e[$LINES;1H\]"
	BAR+="\n"

	if [[ "$HOST" == "sherpa" || "$HOST" == "coinflipper" ]]; then
		BAR+="$(separator -1 $SEPARATOR_COLOR_HOST $COLOR_HOST)"
		BAR+="$(terminalColor $TEXT_COLOR_HOST $COLOR_HOST)$BOLD$HOST"
		BAR+="$(separator $COLOR_HOST $SEPARATOR_COLOR_DIRECTORY $COLOR_DIRECTORY)"
	else
		BAR+="$(separator -1 -1 $COLOR_DIRECTORY)"
	fi

	LATEST_COLOR=$COLOR_DIRECTORY

	BAR+="$(terminalColor $TEXT_COLOR_DIRECTORY $COLOR_DIRECTORY)$BOLD$(workingDirectory)"

	if [[ -n "$GIT" ]]; then
		LATEST_COLOR=$COLOR_GIT

		BAR+="$(separator $COLOR_DIRECTORY $SEPARATOR_COLOR_GIT $COLOR_GIT)"
		BAR+="$(terminalColor $TEXT_COLOR_GIT $COLOR_GIT)$GIT"
	fi

	BAR+="${RESET_COLORS}"

	if (( $PREVIOUS_EXIT_CODE != 0 )); then
		BAR+="$(separator $LATEST_COLOR $SEPARATOR_COLOR_BAD $COLOR_BAD)"
		BAR+="$(terminalColor $TEXT_COLOR_BAD $COLOR_BAD)"

		LATEST_COLOR=$COLOR_BAD
	else
		BAR+="$(separator $LATEST_COLOR $SEPARATOR_COLOR_GOOD $COLOR_GOOD)"
		BAR+="$(terminalColor $TEXT_COLOR_GOOD $COLOR_GOOD)"

		LATEST_COLOR=$COLOR_GOOD
	fi

	BAR+="\\$"

	#BAR+="$(terminalColor $SEPARATOR_COLOR $LATEST_COLOR)▐"
	BAR+="$(separator $LATEST_COLOR -1 -1) "
	echo -e "$BAR"
}

function printPrompt() {
	SEPARATOR="∵"
	PREVIOUS_EXIT_CODE=$1

	GIT=$(parse_git_branch)
	HOST=$(hostname -s)

	TEXT_COLOR_HOST=82
	TEXT_COLOR_DIRECTORY=81
	TEXT_COLOR_GIT=171
	TEXT_COLOR_GOOD=255
	TEXT_COLOR_SEPARATOR=245

	PROMPT=""

	if [[ -n "$SSH_CLIENT" ]]; then
		PROMPT+="$(terminalColor $TEXT_COLOR_HOST)$BOLD$HOST"
		PROMPT+="$(terminalColor $TEXT_COLOR_SEPARATOR) $SEPARATOR "
	fi

	PROMPT+="$(terminalColor $TEXT_COLOR_DIRECTORY)$BOLD$(workingDirectory)"

	if [[ -n "$GIT" ]]; then
		PROMPT+="$(terminalColor $TEXT_COLOR_SEPARATOR) $SEPARATOR "
		PROMPT+="$(terminalColor $TEXT_COLOR_GIT)$BOLD$GIT"
	fi

	PROMPT+="${RESET_COLORS}"
	PROMPT+="$(terminalColor $TEXT_COLOR_GOOD)"
	PROMPT+=" \\$"

	#PROMPT+="$BOLD$(terminalColor 0 32) $(workingDirectory) $(terminalColor 32 40)▆$(terminalColor 40 32)▀$RESET_COLORS$(terminalColor 32 40)▂$(terminalColor 40 0)█$(terminalColor 0 40)master $RESET_COLORS"
	#➔ ${BOLD}mas${NORMAL}ter"

	echo -e "$PROMPT"
}

function separator() {
	SEPARATOR_LEFT="█▛"
	SEPARATOR_RIGHT="▟█"

	if [[ "$1" -ne "-1" ]]; then
		OUTPUT+="$(terminalColor $1 $2)$SEPARATOR_LEFT"
	fi

	if [[ "$3" -ne "-1" ]]; then
		OUTPUT+="$(terminalColor $3 $2)$SEPARATOR_RIGHT"
	fi

	echo $OUTPUT
}

function terminalColor() {
	FOREGROUND="\[\e[38;5;${1}m\]"
	BACKGROUND="\[\e[48;5;${2}m\]"

	if [[ -z "${1}" ]]; then
		FOREGROUND="\[\e[38;5;15m\]"
	fi

	if [[ -z "${2}" || "${2}" -eq "-1" ]]; then
		BACKGROUND=""
	fi

	echo ${RESET_COLORS}${FOREGROUND}${BACKGROUND}
}

function workingDirectory() {
	HIERARCHY=($(echo $PWD \
		| sed -e "s|^$HOME|~|" \
		| sed -e "s| |!SPACE!|g" \
		| sed -e "s|/| |g"
	))

	OUTPUT=""

	if (( ${#HIERARCHY[@]} > 0 )); then
		for i in $(seq 0 $((${#HIERARCHY[@]} - 1))); do
			if [[ $i -eq 0 && "${HIERARCHY[$i]}" != "~" ]]; then
				OUTPUT+="/"
			fi

			if (( $i > 0 )); then
				OUTPUT+="/"
			fi

			if (( $i < $((${#HIERARCHY[@]} - 1)) )); then
				if [[ ${HIERARCHY[$i]:0:1} =~ [^A-Za-z0-9] ]]; then
					OUTPUT+="${HIERARCHY[$i]:0:2}"
				else
					OUTPUT+="${HIERARCHY[$i]:0:1}"
				fi
			else
				OUTPUT+="${HIERARCHY[$i]//!SPACE!/ }"
			fi
		done
	else
		OUTPUT+="/"
	fi

	echo -e "$OUTPUT"
}

function set_bash_prompt() {
	#PS1="\w \$ \$(parse_git_branch"
	#PS1="\w $(parse_git_branch)\\$ $(printTitlebar)"
	#PS1="$(printTitlebar)$(parse_git_branch)\\$ "

	#PS1="$(printBar $?)$RESET_COLORS"
	PS1="$(printPrompt $?)$RESET_COLORS "

	#PS0="\n"
}

function trans() {
  grep $* ~/Workspace/chess/app/Resources/assets/js/translations/messages.en_US.json
}

function route() {
  grep -Rn $* ~/Workspace/chess/src/Chess/WebBundle/Resources/config/routing/*
}

PROMPT_COMMAND=set_bash_prompt

export CLICOLOR=1
export LSCOLORS=ExGxxxxxCxxxxxxxxxxxxx
export BASH_SILENCE_DEPRECATION_WARNING=1
export TERM=xterm

source /Library/Developer/CommandLineTools/usr/share/git-core/git-completion.bash

alias chess="cd ~/Workspace/chess"
alias legacy="cd ~/Workspace/chess/client/web/puzzles-legacy"
alias battle="cd ~/Workspace/chess/client/web/puzzles/modules/puzzle-battle"
alias core="cd ~/Workspace/chess/client/web/puzzles/modules/puzzle-core"
alias rush="cd ~/Workspace/chess/client/web/puzzles/modules/puzzle-rush"
alias tests="cd ~/Workspace/chess/client/tests/cypress/e2e"
alias fixtures="cd ~/Workspace/chess/client/tests/cypress/fixtures"
alias compile="~/Workspace/chess/client/build/bin/build compile"
alias serve-cypress="~/Workspace/chess/client/build/bin/build serve --cypress -u"
alias serve-docker="~/Workspace/chess/client/build/bin/build serve --docker -u"
alias type-check="~/Workspace/chess/client/build/bin/build run type-check"
alias lint-scripts="~/Workspace/chess/client/build/bin/build run ci:lint-scripts"
alias lint-styles="~/Workspace/chess/client/build/bin/build run ci:lint-styles"
