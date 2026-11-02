"""Tests for claude_comment_prefix.

Run from anywhere:
    /usr/bin/python3 -B -m unittest discover \
        -s ~/dotfiles/claude/hooks -p '*_test.py'
"""

import unittest

from claude_comment_prefix import check

REPLIES = "gh api repos/o/r/pulls/1/comments/5/replies"


class CheckTest(unittest.TestCase):
    def test_reading_comments_passes(self):
        command = "gh api repos/o/r/pulls/1/comments --jq '.[]'"
        self.assertIsNone(check(command))

    def test_unrelated_gh_command_passes(self):
        self.assertIsNone(check("gh pr view 12168"))

    def test_reply_with_prefix_passes(self):
        self.assertIsNone(check(f"{REPLIES} -f body='claude: Fixed in abc'"))

    def test_reply_without_prefix_is_blocked(self):
        self.assertIsNotNone(check(f"{REPLIES} -f body='Fixed in abc'"))

    def test_heredoc_reply_with_prefix_passes(self):
        command = (
            f"{REPLIES} -f body=\"$(cat <<'EOF'\n"
            "claude: Fixed in abc. It's done.\nEOF\n)\""
        )
        self.assertIsNone(check(command))

    def test_heredoc_reply_without_prefix_is_blocked(self):
        command = f"{REPLIES} -f body=\"$(cat <<'EOF'\nFixed in abc\nEOF\n)\""
        self.assertIsNotNone(check(command))

    def test_reply_from_file_is_blocked(self):
        self.assertIsNotNone(check(f"{REPLIES} -F body=@reply.md"))

    def test_pr_comment_with_prefix_passes(self):
        self.assertIsNone(check("gh pr comment 1 --body 'claude: hi'"))

    def test_pr_comment_without_prefix_is_blocked(self):
        self.assertIsNotNone(check("gh pr comment 1 --body 'hi'"))

    def test_pr_comment_from_body_file_is_blocked(self):
        self.assertIsNotNone(check("gh pr comment 1 --body-file x.md"))

    def test_bold_prefix_is_blocked(self):
        self.assertIsNotNone(check("gh pr comment 1 --body '**claude:** hi'"))

    def test_graphql_resolve_passes(self):
        command = (
            "gh api graphql -f query='mutation { resolveReviewThread("
            'input:{threadId:"T"}) { thread { id } } }\''
        )
        self.assertIsNone(check(command))

    def test_graphql_reply_without_prefix_is_blocked(self):
        command = (
            "gh api graphql -f query='mutation { "
            'addPullRequestReviewThreadReply(input:{body:"hi"}) '
            "{ comment { id } } }'"
        )
        self.assertIsNotNone(check(command))

    def test_graphql_reply_with_prefix_passes(self):
        command = (
            "gh api graphql -f query='mutation { "
            'addPullRequestReviewThreadReply(input:{body:"claude: hi"}) '
            "{ comment { id } } }'"
        )
        self.assertIsNone(check(command))


if __name__ == "__main__":
    unittest.main()
