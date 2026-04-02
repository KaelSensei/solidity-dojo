#!/usr/bin/env python3
"""Apply Slither naming-convention fixes from slither-report.json (dry-run safe: writes files)."""
from __future__ import annotations

import json
import re
import sys
from collections import defaultdict
from pathlib import Path

REPORT = Path("slither-report.json")
ROOT = Path(__file__).resolve().parents[1]


def word_repl(text: str, old: str, new: str) -> str:
    pat = re.compile(r"(?<![a-zA-Z0-9_])" + re.escape(old) + r"(?![a-zA-Z0-9_])")
    return pat.sub(new, text)


def to_mixed_case_from_caps(name: str) -> str:
    """MY_UINT -> myUint, DOMAIN_SEPARATOR handled elsewhere."""
    if "_" in name:
        parts = [p for p in name.split("_") if p]
        if not parts:
            return name.lower()
        head = parts[0].lower()
        tail = "".join(p.capitalize() for p in parts[1:])
        return head + tail
    if len(name) == 1:
        return name.lower()
    return name[0].lower() + name[1:]


def suggest_new_name(name: str, contract: str | None) -> str:
    if name.startswith("_"):
        return name[1:]
    if name == "DOMAIN_SEPARATOR":
        return "domainSeparator"
    if name == "A" and contract == "StableSwapAMM":
        return "amplificationCoefficient"
    if name.isupper() or (len(name) > 1 and name[0].isupper() and "_" in name):
        return to_mixed_case_from_caps(name)
    return name


def main() -> int:
    if not REPORT.exists():
        print("Missing slither-report.json — run: bash scripts/slither-summary.sh", file=sys.stderr)
        return 1

    data = json.loads(REPORT.read_text(encoding="utf-8"))
    detectors = data["results"]["detectors"]

    # (relative_path, start_line, end_line) -> {old: new}
    ranges: dict[tuple[str, int, int], dict[str, str]] = defaultdict(dict)
    function_renames: dict[tuple[str, str], str] = {}  # (file, old_fn) -> new_fn

    for det in detectors:
        if det["check"] != "naming-convention":
            continue
        el0 = det["elements"][0]
        etype = el0["type"]

        if etype == "function":
            fname = el0["name"]
            rel = el0["source_mapping"]["filename_short"]
            new_fn = fname.replace("_UNOPTIMIZED", "Unoptimized")
            if new_fn != fname:
                function_renames[(rel, fname)] = new_fn
            continue

        if etype != "variable":
            continue

        name = el0["name"]
        rel = el0["source_mapping"]["filename_short"]
        if rel.startswith("src/hacks/"):
            continue

        parent = el0.get("type_specific_fields", {}).get("parent", {})
        contract_name = None
        if parent.get("type") == "contract":
            contract_name = parent.get("name")
            lines = parent["source_mapping"].get("lines", [])
        elif parent.get("type") == "function":
            gp = parent.get("type_specific_fields", {}).get("parent", {})
            if gp.get("type") == "contract":
                contract_name = gp.get("name")
            lines = parent["source_mapping"].get("lines", [])
        else:
            lines = []

        if not lines:
            continue

        lo, hi = min(lines), max(lines)
        new_name = suggest_new_name(name, contract_name)
        if new_name == name:
            continue

        bucket = ranges[(rel, lo, hi)]
        if name in bucket and bucket[name] != new_name:
            print(f"Conflict {rel} L{lo}-{hi}: {name} -> {bucket[name]} vs {new_name}", file=sys.stderr)
            return 2
        bucket[name] = new_name

    # Apply function renames file-wise (full file)
    by_file_fn: dict[str, dict[str, str]] = defaultdict(dict)
    for (rel, old), new in function_renames.items():
        by_file_fn[rel][old] = new

    for rel, mapping in by_file_fn.items():
        path = ROOT / rel
        text = path.read_text(encoding="utf-8")
        for old, new in sorted(mapping.items(), key=lambda x: len(x[0]), reverse=True):
            text = word_repl(text, old, new)
        path.write_text(text, encoding="utf-8", newline="\n")
        print(f"renamed functions in {rel}: {mapping}")

    # Apply variable renames per function range
    by_path: dict[str, list[tuple[int, int, dict[str, str]]]] = defaultdict(list)
    for (rel, lo, hi), mapping in ranges.items():
        if not mapping:
            continue
        by_path[rel].append((lo, hi, mapping))

    for rel, chunks in by_path.items():
        path = ROOT / rel
        lines = path.read_text(encoding="utf-8").split("\n")
        # process smaller inner ranges first if nested? sort by span length ascending
        chunks.sort(key=lambda x: (x[1] - x[0], x[0]))
        for lo, hi, mapping in chunks:
            segment = "\n".join(lines[lo - 1 : hi])
            for old, new in sorted(mapping.items(), key=lambda x: len(x[0]), reverse=True):
                segment = word_repl(segment, old, new)
            new_lines = segment.split("\n")
            lines[lo - 1 : hi] = new_lines
        path.write_text("\n".join(lines) + "\n", encoding="utf-8", newline="\n")
        print(f"updated {rel} ({len(chunks)} span(s))")

    return 0


if __name__ == "__main__":
    raise SystemExit(main())
