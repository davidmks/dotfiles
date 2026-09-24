#!/usr/bin/env bash

# Required parameters:
# @raycast.schemaVersion 1
# @raycast.title Jump to Agent
# @raycast.mode silent

# Optional parameters:
# @raycast.packageName Claude Agents
# @raycast.description Jump to the Claude agent that waited longest.

set -u

readonly TERMINAL_BUNDLE_ID="com.mitchellh.ghostty"

main() {
  local message
  message="$("${HOME}/.claude/hooks/agent-state.sh" jump)"
  # Raycast shows the last line of output, such as "No agents waiting".
  if [[ -n "${message}" ]]; then
    echo "${message}"
    return 0
  fi
  open -b "${TERMINAL_BUNDLE_ID}"
}

main "$@"
