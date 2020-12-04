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
  #GOOD_COLORS=(1 2 3 4 5 6 7)
  #echo -e "${CLEAR_LINE}$(terminalColor 245 ${GOOD_COLORS[$(($RANDOM % ${#GOOD_COLORS[@]}))]})\\w $(parse_git_branch)${CLEAR_LINE}${RESET_COLORS}"
  #COOL_CHARS=(▘ ▝ ▀ ▖ ▍ ▞ ▛ ▗ ▚ ▐ ▜ ▃ ▙ ▟ ▉)

  COLOR0=0
  COLOR1=33
  COLOR2=99
  COLOR_GOOD=34
  COLOR_BAD=196
  TEXT_COLOR=15
  TEXT_COLOR1=195
  TEXT_COLOR2=225
  TEXT_COLOR_BAD=224
  TEXT_COLOR_GOOD=194
  SEPARATOR_COLOR=255

  COLOR0=0
  COLOR1=17
  COLOR2=53
  COLOR_GOOD=22
  COLOR_BAD=124
  TEXT_COLOR=15
  TEXT_COLOR1=111
  TEXT_COLOR2=176
  TEXT_COLOR_BAD=224
  TEXT_COLOR_GOOD=114
  SEPARATOR_COLOR=-1

  LATEST_COLOR=$COLOR1

  BAR="${CLEAR_LINE}"
  #BAR+="$(terminalColor $SEPARATOR_COLOR $COLOR1)▌"
  BAR+="$(separator -1 $SEPARATOR_COLOR $COLOR1)"
  BAR+="$(terminalColor $TEXT_COLOR1 $COLOR1)$BOLD$(workingDirectory)"

  GIT=$(parse_git_branch)

  if [[ -n "$GIT" ]]; then
    LATEST_COLOR=$COLOR2

    BAR+="$(separator $COLOR1 $SEPARATOR_COLOR $COLOR2)"
    BAR+="$(terminalColor $TEXT_COLOR2 $COLOR2)$GIT"
  fi

  BAR+="${RESET_COLORS}"

  if [[ $1 != 0 ]]; then
    BAR+="$(separator $LATEST_COLOR $SEPARATOR_COLOR $COLOR_BAD)"
    BAR+="$(terminalColor $TEXT_COLOR_BAD $COLOR_BAD)"

    LATEST_COLOR=$COLOR_BAD
  else
    BAR+="$(separator $LATEST_COLOR $SEPARATOR_COLOR $COLOR_GOOD)"
    BAR+="$(terminalColor $TEXT_COLOR_GOOD $COLOR_GOOD)"

    LATEST_COLOR=$COLOR_GOOD
  fi

  BAR+="\$"

  #BAR+="$(terminalColor $SEPARATOR_COLOR $LATEST_COLOR)▐"
  BAR+="$(separator $LATEST_COLOR $SEPARATOR_COLOR -1) "
  echo -e "$BAR"
}

function printPrompt() {
  #COOL_CHARS=(▘ ▝ ▀ ▖ ▍ ▞ ▛ ▗ ▚ ▐ ▜ ▃ ▙ ▟ ▉)
  PROMPT=""

  PROMPT+="$(terminalColor 32 0)$BOLD$(workingDirectory)$RESET_COLORS"

  GIT=$(parse_git_branch)

  if [[ -n "$GIT" ]]; then
    PROMPT+=" $(terminalColor 250 0)◿◸$RESET_COLORS $(terminalColor 40 0)${BOLD}$GIT$RESET_COLORS"
  fi

  #PROMPT+="$BOLD$(terminalColor 0 32) $(workingDirectory) $(terminalColor 32 40)▆$(terminalColor 40 32)▀$RESET_COLORS$(terminalColor 32 40)▂$(terminalColor 40 0)█$(terminalColor 0 40)master $RESET_COLORS"
  #➔ ${BOLD}mas${NORMAL}ter"

  echo -e "$PROMPT "
}

function separator() {
  if [[ "$1" -ne "-1" ]]; then
    OUTPUT+="$(terminalColor $1 $2)█▛"
  fi

  if [[ "$3" -ne "-1" ]]; then
    OUTPUT+="$(terminalColor $3 $2)▟█"
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
    | sed -e "s|/| |g"
  ))

  OUTPUT=""

  if (( ${#HIERARCHY[@]} > 0 )); then
    for i in $(seq 0 $((${#HIERARCHY[@]} - 1))); do
      if [[ $i -eq 0 && "${HIERARCHY[$i]}" != "~" ]]; then
        OUTPUT+="/"
      fi

      if [[ $i -gt 0 ]]; then
        OUTPUT+="/"
      fi

      if [[ $i -lt $((${#HIERARCHY[@]} - 1)) ]]; then
        OUTPUT+="${HIERARCHY[$i]:0:1}"
      else
        OUTPUT+="${HIERARCHY[$i]}"
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
  PS1="$(printBar $?)$RESET_COLORS"
  #PS1="$(printPrompt $?)$BOLD\$$RESET_COLORS "
}

PROMPT_COMMAND=set_bash_prompt

export DEV_DOMAIN=pnancedev.14four.com
