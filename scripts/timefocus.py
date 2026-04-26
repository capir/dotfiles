#!/usr/bin/env python3
"""timefocus — auto-track focus to taskwarrior/timewarrior."""
from __future__ import annotations

__version__ = "0.1.0"

def main(argv: list[str] | None = None) -> int:
    import sys
    argv = sys.argv[1:] if argv is None else argv
    if argv == ["--version"]:
        print(__version__)
        return 0
    print("timefocus: not yet implemented", file=sys.stderr)
    return 2

if __name__ == "__main__":
    raise SystemExit(main())
