import pytest
from timefocus import parse_ticket

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
