"""Trim the leading silence off the source sounds into Media/Sounds.

A clip that starts with silence lands late: the addon plays it the moment a
spell is ready, but the audible part arrives milliseconds afterwards. Sources
live in art/sounds and are copied byte for byte unless they actually begin
with silence, so only the files that need it are re-encoded.

Run from the repo root:  python tools/build_sounds.py
Requires soundfile.
"""
import os
import shutil

import numpy as np
import soundfile as sf

ROOT = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
SRC = os.path.join(ROOT, "art", "sounds")
OUT = os.path.join(ROOT, "Media", "Sounds")

# Below this the delay is inaudible and not worth a second encode.
THRESHOLD_MS = 15
# Kept in front of the first audible sample so the attack is not clipped.
GUARD_MS = 4


def lead_seconds(data, rate):
    mono = np.abs(data).max(axis=1)
    peak = mono.max()
    if peak <= 0:
        return 0.0
    level = max(peak * 0.01, 1e-4)
    loud = np.flatnonzero(mono > level)
    return (loud[0] / rate) if len(loud) else 0.0


def main():
    os.makedirs(OUT, exist_ok=True)
    trimmed = copied = 0

    for name in sorted(os.listdir(SRC)):
        if not name.lower().endswith(".ogg"):
            continue
        src, dst = os.path.join(SRC, name), os.path.join(OUT, name)
        data, rate = sf.read(src, always_2d=True)
        lead = lead_seconds(data, rate)

        if lead * 1000 < THRESHOLD_MS:
            shutil.copyfile(src, dst)
            copied += 1
            continue

        start = max(0, int((lead - GUARD_MS / 1000) * rate))
        sf.write(dst, data[start:], rate, format="OGG", subtype="VORBIS")
        trimmed += 1
        print(f"{name:28} trimmed {lead * 1000:7.1f} ms")

    print(f"{trimmed} trimmed, {copied} copied unchanged")


if __name__ == "__main__":
    main()
