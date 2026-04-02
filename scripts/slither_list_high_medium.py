#!/usr/bin/env python3
from __future__ import annotations

import json
from collections import defaultdict
from pathlib import Path


def main() -> int:
    root = Path(__file__).resolve().parents[1]
    import sys
    filename = sys.argv[1] if len(sys.argv) > 1 else "slither-full.json"
    path = root / filename
    data = json.loads(path.read_text(encoding="utf-8"))
    dets = data.get("results", {}).get("detectors", []) or []

    by_impact: dict[str, list[dict]] = defaultdict(list)
    for d in dets:
        impact = (d.get("impact") or d.get("severity") or "unknown").lower()
        by_impact[impact].append(d)

    for impact in ("high", "medium"):
        bucket = by_impact.get(impact, [])
        print(f"\n== {impact} == {len(bucket)}")
        for d in bucket:
            check = d.get("check") or d.get("type") or "unknown"
            desc = (d.get("description") or "").splitlines()[0]
            loc = None
            for el in d.get("elements") or []:
                sm = el.get("source_mapping") or {}
                fn = sm.get("filename_relative") or sm.get("filename")
                if fn:
                    loc = f"{fn}#{sm.get('starting_line')}-{sm.get('ending_line')}"
                    break
            print(f"- {check}: {loc} :: {desc[:140]}")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())

