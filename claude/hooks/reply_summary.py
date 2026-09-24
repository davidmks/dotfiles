"""Prints one sentence that sums up a Claude Code reply, for a notification.

Reads the reply on stdin. When the last paragraph asks a question, prints that
question from the start of its sentence, because that is what the agent needs
from you. Otherwise prints the reply's first sentence. Skips code blocks.

Runs on the macOS system Python (3.9), so it avoids newer syntax.
"""

import re
import sys

PARAGRAPH_BREAK = re.compile(r"\n\s*\n")
# A "?" followed by a space or the end, so "x?.y" in code does not count.
QUESTION_MARK = re.compile(r"\?(?=\s|$)")
SENTENCE_END = re.compile(r"[.!]\s+")
FIRST_SENTENCE = re.compile(r"^(.*?[.!])(?=\s|$)", re.DOTALL)


def summarize(reply: str) -> str:
    """Returns the question in the last paragraph, else the first sentence.

    Args:
        reply: The agent's full reply, usually Markdown.

    Returns:
        One sentence of the reply, or "" when the reply has no prose.
    """
    paragraphs = [
        paragraph
        for paragraph in PARAGRAPH_BREAK.split(reply.strip())
        if not paragraph.lstrip().startswith("```")
    ]
    if not paragraphs:
        return ""

    last = paragraphs[-1]
    question_ends = [match.end() for match in QUESTION_MARK.finditer(last)]
    if question_ends:
        end = question_ends[-1]
        sentence_starts = [
            match.end() for match in SENTENCE_END.finditer(last, 0, end)
        ]
        start = sentence_starts[-1] if sentence_starts else 0
        return last[start:end]

    first_sentence = FIRST_SENTENCE.match(paragraphs[0])
    if first_sentence is not None:
        return first_sentence.group(1)
    return paragraphs[0]


def main() -> None:
    """Reads a reply on stdin and prints its summary without a newline."""
    print(summarize(sys.stdin.read()), end="")


if __name__ == "__main__":
    main()
