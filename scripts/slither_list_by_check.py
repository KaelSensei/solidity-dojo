#!/usr/bin/env python3
from __future__ import annotations

import json
import sys
from pathlib import Path


def main() -> int:
    if len(sys.argv) < 2:
        print("usage: slither_list_by_check.py <slither-json> [check] [impact]")
        return 2

    root = Path(__file__).resolve().parents[1]
    path = root / sys.argv[1]
    check_filter = sys.argv[2] if len(sys.argv) > 2 else None
    impact_filter = sys.argv[3].lower() if len(sys.argv) > 3 else None

    data = json.loads(path.read_text(encoding="utf-8"))
    dets = data.get("results", {}).get("detectors", []) or []
    for d in dets:
        check = d.get("check") or d.get("type") or "unknown"
        impact = (d.get("impact") or d.get("severity") or "unknown").lower()
        if check_filter and check != check_filter:
            continue
        if impact_filter and impact != impact_filter:
            continue

        loc = None
        for el in d.get("elements") or []:
            sm = el.get("source_mapping") or {}
            fn = sm.get("filename_relative") or sm.get("filename")
            if fn:
                loc = f"{fn}#{sm.get('starting_line')}-{sm.get('ending_line')}"
                break
        desc = (d.get("description") or "").splitlines()[0]
        print(f"- {impact} {check}: {loc} :: {desc[:140]}")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())

