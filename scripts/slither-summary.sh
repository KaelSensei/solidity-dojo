#!/usr/bin/env bash
FILTER='(src/hacks|lib|test|script)(/|$)'
slither . --filter-paths "$FILTER" --json slither-report.json || true
python3 <<'PY'
import json
import os
from collections import Counter
path = "slither-report.json"
if not os.path.exists(path):
    print("no report")
    raise SystemExit(1)
with open(path) as f:
    d = json.load(f)
results = d.get("results", [])
c = Counter(r["check"] for r in results)
print("total_findings", len(results))
for check, n in c.most_common(60):
    print(n, check)
PY
