from __future__ import annotations
from timefocus import trim_intervals_text, Config

SAMPLE = """\
inc 20260425T080000Z - 20260425T080015Z # "TOS-9 short"
inc 20260425T081000Z - 20260425T084500Z # "TOS-9 ok"
inc 20260425T100000Z - 20260425T100020Z # "TOSS-1 short"
inc 20260425T110000Z - 20260425T120000Z # "TOS-9 long"
"""

def test_trim_drops_intervals_under_threshold():
    cfg = Config(min_chunk_s=30)
    out, dropped = trim_intervals_text(SAMPLE, cfg=cfg)
    assert dropped == 2
    assert "20260425T080000Z" not in out
    assert "20260425T100000Z" not in out
    assert "20260425T081000Z" in out
    assert "20260425T110000Z" in out
