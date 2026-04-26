import pytest
from pathlib import Path
from timefocus import parse_ticket, decode_claude_session_dir

@pytest.mark.parametrize("branch,expected", [
    ("catalin/tos-9-add-thing", "TOS-9"),
    ("feature/TOSS-1003-something", "TOSS-1003"),
    ("hotfix/TOS-42", "TOS-42"),
    ("tos-1", "TOS-1"),
    ("master", None),
    ("tos-", None),
    ("foo/bar", None),
    ("", None),
])
def test_parse_ticket(branch, expected):
    assert parse_ticket(branch) == expected


def test_decode_claude_session_dir_simple():
    d = "-Users-c-work-TOS-code-base-api-bare-toco"
    assert str(decode_claude_session_dir(d)) == "/Users/c/work/TOS/code_base_api_bare/toco"

def test_decode_claude_session_dir_no_leading_dash():
    assert decode_claude_session_dir("foobar") is None
