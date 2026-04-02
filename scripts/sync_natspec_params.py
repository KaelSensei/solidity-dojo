#!/usr/bin/env python3
"""Sync NatSpec @param names: strip leading underscore to match mixedCase parameters."""
from __future__ import annotations

import re
import sys
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
PARAM_RE = re.compile(r"^(?P<indent>\s*///\s*@param )_(?P<name>[a-zA-Z][a-zA-Z0-9]*)(?P<rest>\s.*)?$")


def main() -> int:
    changed = 0
    for path in sorted(ROOT.glob("src/**/*.sol")):
        if "hacks" in path.parts:
            continue
        text = path.read_text(encoding="utf-8")
        out_lines = []
        for line in text.splitlines():
            m = PARAM_RE.match(line)
            if m:
                rest = m.group("rest") or ""
                line = f"{m.group('indent')}{m.group('name')}{rest}"
                changed += 1
            out_lines.append(line)
        new_text = "\n".join(out_lines) + ("\n" if text.endswith("\n") else "")
        if new_text != text:
            path.write_text(new_text, encoding="utf-8", newline="\n")
    print("touched_lines", changed)
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
