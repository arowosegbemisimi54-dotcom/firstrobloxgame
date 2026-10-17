"""Original procedural radio beds. Python standard library only; no samples.
Rebuild with: python3 scripts/generate_radio_audio.py
"""
import math
from pathlib import Path
import random
import struct
import wave

RATE = 22050
OUT = Path(__file__).resolve().parents[1] / "assets" / "audio"
OUT.mkdir(parents=True, exist_ok=True)

def save(name, duration, synth):
    rng = random.Random(19400417)
    with wave.open(str(OUT / name), "wb") as audio:
        audio.setparams((1, 2, RATE, 0, "NONE", "not compressed"))
        previous = 0
        samples = bytearray()
        for i in range(int(duration * RATE)):
            t = i / RATE
            noise = rng.uniform(-1, 1)
            value = synth(t, noise, previous)
            previous = noise
            # Rounded endpoints make a quiet looping bed without an abrupt pop.
            fade = min(1, t / .08, (duration - t) / .08)
            samples.extend(struct.pack("<h", int(max(-1, min(1, value * fade)) * 32767)))
        audio.writeframes(samples)

def static(t, noise, previous):
    return (noise - previous * .68) * .09 * (.82 + .12 * math.sin(t * 1.3))

def chatter(t, noise, previous):
    value = 0
    # Three nonverbal formant-like voices. These are synthetic babble, not speech.
    for voice, base in enumerate((143, 194, 247)):
        shifted = t + voice * 1.17
        phrase = shifted % 4.7
        if phrase > 1.9:
            continue
        syllable = shifted % .21 / .21
        envelope = math.sin(math.pi * syllable) ** 2
        pitch = base + 13 * math.sin(shifted * 4.1)
        value += envelope * (.034 * math.sin(2 * math.pi * pitch * t)
                             + .017 * math.sin(2 * math.pi * pitch * 3 * t)
                             + .009 * math.sin(2 * math.pi * pitch * 5 * t))
    return value + noise * .003

def squelch(t, noise, previous):
    envelope = math.sin(math.pi * min(1, t / .22)) ** 2
    return envelope * ((noise - previous * .7) * .16 + math.sin(2 * math.pi * 1050 * t) * .025)

save("original-radio-static.wav", 12, static)
save("original-diner-babble.wav", 18, chatter)
save("original-radio-squelch.wav", .22, squelch)
