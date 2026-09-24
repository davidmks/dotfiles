"""Tests for reply_summary.

Run from anywhere:
    /usr/bin/python3 -B -m unittest discover \
        -s ~/dotfiles/claude/hooks -p '*_test.py'
"""

import unittest

from reply_summary import summarize


class SummarizeTest(unittest.TestCase):
    def test_question_in_last_paragraph_wins(self):
        reply = "Done.\n\nWant me to clean it up? I would add the entry."
        self.assertEqual(summarize(reply), "Want me to clean it up?")

    def test_question_starts_at_its_own_sentence(self):
        reply = "Summary.\n\nBoth are small edits. Should I make them?\n"
        self.assertEqual(summarize(reply), "Should I make them?")

    def test_colon_does_not_split_a_question(self):
        self.assertEqual(summarize("Pick one: A or B?"), "Pick one: A or B?")

    def test_question_mark_inside_code_is_not_a_question(self):
        reply = "The value is `x?.y` here. It works."
        self.assertEqual(summarize(reply), "The value is `x?.y` here.")

    def test_question_in_earlier_paragraph_is_ignored(self):
        reply = "Tests pass. Should I explain?\n\nAll done here."
        self.assertEqual(summarize(reply), "Tests pass.")

    def test_without_question_returns_first_sentence(self):
        reply = "The layout is live. It shows:\n\n```\nDemo\n```\n\nIt runs."
        self.assertEqual(summarize(reply), "The layout is live.")

    def test_skips_leading_code_block(self):
        reply = "```\ncode first\n```\n\nThen prose. More."
        self.assertEqual(summarize(reply), "Then prose.")

    def test_paragraph_without_sentence_end_is_returned_whole(self):
        self.assertEqual(summarize("Working on it"), "Working on it")

    def test_leading_blank_lines_are_ignored(self):
        self.assertEqual(summarize("  \n\nHello world.  "), "Hello world.")

    def test_empty_reply(self):
        self.assertEqual(summarize(""), "")


if __name__ == "__main__":
    unittest.main()
