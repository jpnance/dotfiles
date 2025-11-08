BOLD="\[\e[1m\]"
NORMAL="\[\e[22m\]"
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

	echo -e "$PROMPT"
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
	PS1="$(printPrompt $?)$RESET_COLORS "
}

PROMPT_COMMAND=set_bash_prompt
