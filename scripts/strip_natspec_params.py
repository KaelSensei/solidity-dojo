#!/usr/bin/env python3
"""Remove /// @param lines (avoids Solidity 3881 when names drift after refactors)."""
from __future__ import annotations

import re
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
PARAM_LINE = re.compile(r"^\s*///\s*@param\b.*$")


def main() -> int:
    removed = 0
    for path in sorted(ROOT.glob("src/**/*.sol")):
        if "hacks" in path.parts:
            continue
        text = path.read_text(encoding="utf-8")
        lines = text.splitlines()
        new_lines = []
        for line in lines:
            if PARAM_LINE.match(line):
                removed += 1
                continue
            new_lines.append(line)
        new_text = "\n".join(new_lines) + ("\n" if text.endswith("\n") else "")
        if new_text != text:
            path.write_text(new_text, encoding="utf-8", newline="\n")
    print("removed_param_lines", removed)
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
