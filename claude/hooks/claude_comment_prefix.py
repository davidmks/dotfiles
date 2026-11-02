#!/usr/bin/env python3
"""PreToolUse hook: a PR comment Claude posts must start with "claude:".

gh posts as David's GitHub account. The prefix tells readers that Claude
wrote the comment, not David. The hook blocks (exit 2) a posting command
when:

- a comment body does not start with PREFIX;
- the body comes from a file (--body-file, -F body=@file, --input),
  which the hook cannot read.

Commands that only read, or that only resolve a review thread, pass.
Permission rules still ask David before each post.
"""

from __future__ import annotations

import json
import re
import sys

PREFIX = "claude:"
POSTING_GRAPHQL_MUTATIONS = (
    "addPullRequestReviewThreadReply",
    "addPullRequestReviewComment",
    "addComment",
)
BODY_MARKER = re.compile(
    r"--body(?:=|\s+)|(?<![\w-])-b\s+|(?<!\w)body=|(?<!\w)body:\s*"
)
BODY_OPENING = re.compile(
    r"""^[\\"']*(?:\$\(\s*cat\s+<<-?\s*['"]?\w+['"]?\s*\n)?[\\"']*"""
)
FILE_BODY = re.compile(r"--body-file\b|--input\b|(?<!\w)body=@")
REST_COMMENT = re.compile(r"/(pulls|issues)/\S*comments|/replies\b")
FIELD_FLAG = re.compile(r"\s(-f|-F|--field|--raw-field)\s")
GET_METHOD = re.compile(r"(-X|--method)\s+GET\b")


def _block(reason: str) -> None:
    print(
        f"Blocked by claude_comment_prefix hook: {reason} "
        f"Start the body with '{PREFIX} '.",
        file=sys.stderr,
    )
    sys.exit(2)


def is_posting(command: str) -> bool:
    """Tell if the command posts a PR comment or a review thread reply."""
    if re.search(r"\bgh\s+pr\s+comment\b", command):
        return True
    if not re.search(r"\bgh\s+api\b", command):
        return False
    if re.search(r"\bgraphql\b", command):
        return any(name in command for name in POSTING_GRAPHQL_MUTATIONS)
    writes = FIELD_FLAG.search(command) and not GET_METHOD.search(command)
    return bool(REST_COMMENT.search(command) and writes)


def bodies_start_with_prefix(command: str) -> bool | None:
    """Check each inline body, a heredoc body included.

    Return None when the command has no inline body.
    """
    starts = [command[match.end() :] for match in BODY_MARKER.finditer(command)]
    if not starts:
        return None
    return all(
        BODY_OPENING.sub("", start, count=1).lstrip().startswith(PREFIX)
        for start in starts
    )


def check(command: str) -> str | None:
    """Return why the command must be blocked, or None when it may run."""
    if not is_posting(command):
        return None
    if FILE_BODY.search(command):
        return (
            "the comment body comes from a file, so the prefix cannot be "
            "checked. Pass the body inline."
        )
    starts_with_prefix = bodies_start_with_prefix(command)
    if starts_with_prefix is None:
        return "no inline comment body found."
    if not starts_with_prefix:
        return "the comment body does not start with the prefix."
    return None


def main() -> None:
    """Read the PreToolUse payload from stdin and block a bad post."""
    payload = json.load(sys.stdin)
    reason = check(payload.get("tool_input", {}).get("command", ""))
    if reason is not None:
        _block(reason)


if __name__ == "__main__":
    main()
