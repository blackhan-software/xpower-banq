#!/usr/bin/env python

import matplotlib.pyplot as pp
import numpy as np
import argparse

l_colors = ["r", "g", "b", "c", "m", "y", "black"]
b_colors = ["c", "m", "y", "r", "g", "b", "white"]

# Parse command line arguments
parser = argparse.ArgumentParser(description='TWAP-EMA Simulation')
parser.add_argument('--random-seed', '-s', type=int, default=np.random.randint(256), help='Random seed')
parser.add_argument('--total-time', '-tt', type=int, default=240, help='Total time [h] (default=%(default)s)')
parser.add_argument('--delta-time', '-dt', type=int, default=1, help='Time step [h] (default=%(default)s)')
parser.add_argument('--colors', '-c', type=list, default=l_colors, help='Colors (default=%(default)s)')
parser.add_argument('--invert-colors', '-i', action='store_true', help='Invert colors')
parser.add_argument('--png-path', '-png', type=str, default=None, help='PNG path')
args = parser.parse_args()

# Set color scheme
if not args.invert_colors:
    colors = l_colors
else:
    pp.style.use('dark_background')
    colors = b_colors

# Simulation parameters
T, dt = args.total_time, args.delta_time
np.random.seed(args.random_seed)
n_steps = T // dt

# Generate Brownian motion
quote = np.cumsum(np.random.randn(n_steps))

# Compute EMA with λ-decays
decay = np.array([
    0.972, # 24HL
    0.944, # 12HL
    0.891, # 06HL
    0.794, # 03HL
    0.707, # 02HL
    0.501, # 01HL
])

ema = np.zeros((decay.size, n_steps))
for i in range(decay.size): ema[i][0] = quote[0]
for t in range(1, n_steps):
    for i in range(len(decay)):
        curr = (1 - decay[i]) * quote[t] # current quote
        prev = decay[i] * ema[i][t - 1] # previous EMA
        ema[i][t] = curr + prev

# Rate of Change (ROC) of EMA
roc = np.zeros((decay.size, n_steps))
roc[:, :-1] = ema[:, :-1] - ema[:, 1:]

# Compute Z-Score
mean_quote, std_quote = np.mean(quote), np.std(quote)
z_score = (quote - mean_quote) / std_quote

# Plot quotes and EMAs
fig, (ax1, ax2, ax3) = pp.subplots(3, 1, figsize=(17.2, 6.39), gridspec_kw={
    'height_ratios': [2, 1, 1]
}, sharex=True)

# 1st subplot: for quotes and EMAs
ax1.plot(range(T), quote, label="Quotes", ls="--", c=colors[-1])
for e, d, c in zip(ema, decay, ["r", "g", "b", "c", "m", "y"]):
    ax1.plot(range(T), e, label=rf"EMA ($\lambda={d}$)", lw=2, c=c, alpha=0.5)

ax1.legend()
ax1.set_title(f"Brownian Motion (seed={args.random_seed})")
ax1.grid(True, which='major', axis='x', linestyle='dotted', alpha=0.50)
ax1.grid(True, which='major', axis='y', linestyle='dotted', alpha=0.25)
ax1.set_ylabel("Quotes")

# 2nd subplot: for ROC of EMA
for rd, c in zip(roc, ["r", "g", "b", "c", "m", "y"]):
    ax2.plot(range(T), rd, label="Rel. Diff", lw=2, c=c, alpha=0.5)

ax2.grid(True, which='major', axis='x', linestyle='dotted', alpha=0.50)
ax2.grid(True, which='major', axis='y', linestyle='dotted', alpha=0.25)
ax2.set_ylabel("ROC of EMAs")

# 3rd subplot: for Z-Score
ax3.plot(range(T), z_score, label="Z-Score", lw=2, c=colors[0])

ax3.grid(True, which='major', axis='x', linestyle='dotted', alpha=0.50)
ax3.grid(True, which='major', axis='y', linestyle='dotted', alpha=0.25)
ax3.set_xticks(range(0, T + 1, 24)) # daily ticks
ax3.set_yticks(range(-2, 3, 1))
ax3.set_xlabel("Time [hours]")
ax3.set_ylabel("Z-Score")

if args.png_path: # Save the figure as a PNG file
    filename = f"{args.png_path}/twap-ema.{args.random_seed:03d}.png"
    pp.savefig(filename, dpi=100)
else: # Show the figure
    pp.show()
