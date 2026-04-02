import json
from collections import Counter

with open("slither-report.json", encoding="utf-8") as f:
    d = json.load(f)
types = Counter()
for x in d["results"]["detectors"]:
    if x["check"] != "naming-convention":
        continue
    types[x["elements"][0]["type"]] += 1
print(dict(types))
