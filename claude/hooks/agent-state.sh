#!/usr/bin/env bash
#
# Tracks Claude Code agents per tmux pane and notifies you when one waits.
# State lives in pane options: @agent_state (working, blocked, done, idle) and
# @agent_since (epoch seconds). "done" means it finished while you looked away.

set -u

# terminal-notifier runs the click command with a minimal PATH.
PATH="/opt/homebrew/bin:/usr/local/bin:${PATH}"

HOOKS_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
readonly HOOKS_DIR
SELF="${HOOKS_DIR}/$(basename "${BASH_SOURCE[0]}")"
readonly SELF
readonly TERMINAL_BUNDLE_ID="com.mitchellh.ghostty"
# macOS only grants notification permission to the copy in ~/Applications.
readonly NOTIFIER_APP="${HOME}/Applications/terminal-notifier.app"
readonly NOTIFIER="${NOTIFIER_APP}/Contents/MacOS/terminal-notifier"
# The system Python, because a pyenv shim follows each repo's pinned version.
readonly PYTHON="/usr/bin/python3"
readonly MESSAGE_LENGTH=120
# 1 when the pane is active in the active window of an attached session.
readonly ON_SCREEN_FORMAT='#{&&:#{session_attached},#{&&:#{window_active},#{pane_active}}}'

#######################################
# Prints a pane option, or nothing when it is unset or the pane is gone.
# Arguments:
#   Pane target, option name.
#######################################
pane_option() {
  tmux show-options -pqv -t "$1" "$2" 2>/dev/null
}

set_state() {
  local pane="$1" state="$2"
  tmux set-option -p -t "${pane}" @agent_state "${state}" \; \
    set-option -p -t "${pane}" @agent_since "$(date +%s)" \; \
    refresh-client -S 2>/dev/null
}

clear_state() {
  local pane="$1"
  tmux set-option -pu -t "${pane}" @agent_state \; \
    set-option -pu -t "${pane}" @agent_since \; \
    refresh-client -S 2>/dev/null
}

# Succeeds when the pane is on screen and the terminal is the front app.
pane_is_visible() {
  local pane="$1" on_screen front_app
  on_screen="$(tmux display-message -p -t "${pane}" "${ON_SCREEN_FORMAT}")"
  [[ "${on_screen}" == "1" ]] || return 1
  front_app="$(lsappinfo info -only bundleID "$(lsappinfo front)")"
  [[ "${front_app}" == *"\"${TERMINAL_BUNDLE_ID}\""* ]]
}

# Reads text on stdin; prints it on one line, without Markdown markers, cut to
# MESSAGE_LENGTH characters.
shorten() {
  tr '\n\t' '  ' \
    | sed -E 's/[*`#]+//g; s/ +/ /g; s/^ //' \
    | cut -c "1-${MESSAGE_LENGTH}"
}

#######################################
# Prints the task name from the pane title Claude Code sets ("✳ <task name>"),
# or session:window while the pane shows none yet.
#######################################
agent_title() {
  local pane="$1" title
  title="$(tmux display-message -p -t "${pane}" '#{pane_title}' \
    | sed -E 's/^[^[:alnum:]]+ //')"
  if [[ -z "${title}" || "${title}" == "Claude Code" ||
    "${title}" == "$(hostname -s)" ]]; then
    tmux display-message -p -t "${pane}" '#{session_name}:#{window_name}'
  else
    printf '%s\n' "${title}"
  fi
}

#######################################
# Sends a macOS notification in the background. Clicking it jumps to the pane.
# Each pane has one notification at most; a new one replaces the old one.
# Arguments:
#   Pane ID, message.
#######################################
notify() {
  local pane="$1" message="$2"
  "${NOTIFIER}" \
    -title "$(agent_title "${pane}")" \
    -message "${message:-(no message)}" \
    -group "claude-agent-${pane}" \
    -activate "${TERMINAL_BUNDLE_ID}" \
    -execute "'${SELF}' jump '${pane}'" \
    >/dev/null 2>&1 &
}

clear_notification() {
  local pane="$1"
  "${NOTIFIER}" -remove "claude-agent-${pane}" >/dev/null 2>&1 &
}

on_working() {
  local pane="$1" previous
  previous="$(pane_option "${pane}" @agent_state)"
  # Tool hooks fire on every tool call, so skip the write when nothing changes.
  if [[ "${previous}" == "working" ]]; then
    return 0
  fi
  set_state "${pane}" working
  if [[ "${previous}" == "blocked" || "${previous}" == "done" ]]; then
    clear_notification "${pane}"
  fi
}

#######################################
# Marks a finished agent. Notifies only when you are not looking at its pane.
# Arguments:
#   Pane ID, hook event name (Stop or StopFailure), hook JSON.
#######################################
on_stop() {
  local pane="$1" event="$2" input="$3" message error
  if pane_is_visible "${pane}"; then
    set_state "${pane}" idle
    return 0
  fi
  if [[ "${event}" == "StopFailure" ]]; then
    error="$(jq -r '.error_message // .error_type // "API error"' \
      <<<"${input}")"
    message="Stopped: ${error}"
  else
    message="$(jq -r '.last_assistant_message // empty' <<<"${input}" \
      | "${PYTHON}" "${HOOKS_DIR}/reply_summary.py")"
  fi
  set_state "${pane}" "done"
  notify "${pane}" "$(shorten <<<"${message}")"
}

on_blocked() {
  local pane="$1" message="$2"
  set_state "${pane}" blocked
  if ! pane_is_visible "${pane}"; then
    notify "${pane}" "$(shorten <<<"${message}")"
  fi
}

#######################################
# Handles the hook JSON on stdin for the pane in TMUX_PANE (unset outside tmux).
# Always exits 0: any other code makes Claude Code show a hook error.
#######################################
handle_hook() {
  local pane="${TMUX_PANE:-}" input event
  if [[ -z "${pane}" ]]; then
    return 0
  fi
  input="$(cat)"
  event="$(jq -r '.hook_event_name // empty' <<<"${input}")"

  case "${event}" in
    UserPromptSubmit | PreToolUse | PostToolUse | PostToolUseFailure)
      on_working "${pane}"
      ;;
    Stop | StopFailure)
      on_stop "${pane}" "${event}" "${input}"
      ;;
    Notification)
      on_blocked "${pane}" "$(jq -r '.message // empty' <<<"${input}")"
      ;;
    SessionEnd)
      clear_state "${pane}"
      clear_notification "${pane}"
      ;;
  esac
  return 0
}

# Prints "● N | " for agents waiting in other sessions, or nothing.
# The current session's waiting agents show as markers in the window list.
print_status() {
  local current_session="${1:-}" waiting
  waiting="$(tmux list-panes -a -F '#{session_name}	#{@agent_state}' \
    | awk -F '\t' -v current="${current_session}" '
        $1 != current && ($2 == "blocked" || $2 == "done") { count++ }
        END { print count + 0 }')"
  if ((waiting > 0)); then
    printf '● %s | ' "${waiting}"
  fi
}

#######################################
# Prints the pane that waited longest, blocked agents before finished ones.
# Inside tmux it skips the pane you are in, so pressing the key again moves
# on. From outside tmux (Raycast, a banner click) that pane may be the one
# waiting, since you were looking at another app.
#######################################
next_waiting_pane() {
  local current=""
  if [[ -n "${TMUX:-}" ]]; then
    current="$(tmux display-message -p '#{pane_id}' 2>/dev/null)"
  fi
  tmux list-panes -a -F '#{@agent_state} #{@agent_since} #{pane_id}' \
    | awk -v current="${current}" '
        $3 == current { next }
        $1 == "blocked" { print 0, $2, $3 }
        $1 == "done" { print 1, $2, $3 }' \
    | sort -n -k1,1 -k2,2 \
    | awk 'NR == 1 { print $3 }'
}

# Clears the banner of an agent you are now looking at; a finished one becomes
# "idle".
mark_seen() {
  local pane="$1"
  case "$(pane_option "${pane}" @agent_state)" in
    "done")
      set_state "${pane}" idle
      clear_notification "${pane}"
      ;;
    blocked)
      clear_notification "${pane}"
      ;;
  esac
}

#######################################
# Switches tmux to an agent's pane and marks it seen. When no agent waits,
# says so in tmux, or on stdout when run from outside tmux (like Raycast).
# Arguments:
#   Optional tmux target; without one, the agent that waited longest.
#######################################
jump() {
  local target="${1:-}" pane
  if [[ -z "${target}" ]]; then
    pane="$(next_waiting_pane)"
  else
    pane="$(tmux display-message -p -t "${target}" '#{pane_id}')"
  fi
  if [[ -z "${pane}" ]]; then
    if [[ -n "${TMUX:-}" ]]; then
      tmux display-message "No agents waiting"
    else
      echo "No agents waiting"
    fi
    return 0
  fi
  tmux switch-client -t "${pane}" \; \
    select-window -t "${pane}" \; \
    select-pane -t "${pane}"
  mark_seen "${pane}"
}

usage() {
  printf 'usage: %s hook | status [SESSION] | jump [TARGET] | seen PANE\n' \
    "$(basename "$0")" >&2
}

main() {
  case "${1:-}" in
    hook) handle_hook ;;
    status) print_status "${2:-}" ;;
    jump) jump "${2:-}" ;;
    seen) mark_seen "${2:?pane ID required}" ;;
    *)
      usage
      exit 2
      ;;
  esac
}

main "$@"
