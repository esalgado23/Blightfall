"""Syntax-check every Lua file the .toc loads. Run before committing."""
import os, re, sys
from luaparser import ast

root = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
toc = open(os.path.join(root, "Blightfall.toc"), encoding="utf-8").read()
files = [l.strip() for l in toc.splitlines() if l.strip().lower().endswith(".lua")]

bad = 0
for f in files:
    path = os.path.join(root, f)
    try:
        ast.parse(open(path, encoding="utf-8").read())
        print(f"{f:16} OK")
    except Exception as e:
        bad += 1
        print(f"{f:16} SYNTAX ERROR: {str(e)[:200]}")

# Sound paths are always relative to Media/; bare Fonts\ paths are WoW's own.
src = "".join(open(os.path.join(root, f), encoding="utf-8").read() for f in files)
media = set(re.findall(r'"(Sounds\\[^"]+)"', src))
media |= {m for m in re.findall(r'MEDIA \.\. "([^"]+)"', src)}
for rel in sorted(media):
    p = os.path.join(root, "Media", rel.replace("\\\\", os.sep).replace("\\", os.sep))
    if not os.path.exists(p):
        bad += 1
        print(f"MISSING MEDIA: {rel}")

print("FAILED" if bad else "All checks passed")
sys.exit(1 if bad else 0)
