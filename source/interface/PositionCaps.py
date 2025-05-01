#!/usr/bin/env python

import matplotlib.pyplot as pp
import numpy as np
import argparse

def simplot(samples, seed=None, tight=False):
    # Set the random seed for reproducibility, if provided.
    if seed is not None:
        np.random.seed(seed)

    N = samples

    # Sample parameters:
    a = np.random.uniform(1, 11, N)
    b = np.random.uniform(1, 11, N)
    t = np.random.uniform(1, 11, N)
    n = np.random.randint(1, 101, N)
    cap = np.random.uniform(1, 101, N)

    # Compute LHS and RHS.
    LHS = a / (b*(t-b)**2 / t**3)
    RHS = 12 * cap / np.sqrt(n+2)

    # Check which samples satisfy the inequality.
    valid = LHS <= RHS
    # Compute share in percent.
    share_percentage = valid.mean() * 100

    # Create side-by-side subplots.
    fig, axs = pp.subplots(1, 2, figsize=(14, 6))

    # Scatter plot: Use logarithmic scales for both axes.
    ax = axs[0]
    ax.scatter(
        LHS[valid], RHS[valid], color='green',
        label='Inequality holds', alpha=0.5)
    ax.scatter(
        LHS[~valid], RHS[~valid], color='red',
        label='Inequality fails', alpha=0.5)

    min_val = min(LHS.min(), RHS.min())
    max_val = max(LHS.max(), RHS.max())
    ax.plot(
        [min_val, max_val], [min_val, max_val], 'k--',
        label='Equality line')

    ax.set_xlabel('a/[b(t-b)²/t³]')
    ax.set_ylabel('12cap/sqrt(n+2)')
    ax.set_title(f'LHS vs. RHS: a/[b(t-b)²/t³] ≤ 12cap/sqrt(n+2)')
    ax.legend()
    ax.grid(True)

    # Set both axes to logarithmic scale.
    ax.set_xscale('log')
    ax.set_yscale('log')

    # Histogram of the differences (LHS - RHS)
    ax = axs[1]
    difference = LHS - RHS
    ax.hist(difference, bins=50, color='blue', alpha=0.7)
    ax.axvline(0, color='k', linestyle='dashed', linewidth=1)

    ax.set_xlabel('a/[b(t-b)²/t³] - 12cap/sqrt(n+2)')
    ax.set_ylabel('Frequency')
    ax.set_title(f'Histogram of Diffs (LHS - RHS ≤ 0: {share_percentage:.2f}%)')
    ax.grid(True)

    if tight: pp.tight_layout()
    pp.show()

def main():
    parser = argparse.ArgumentParser(
        description='Simulate and plot an inequality by sampling parameters.')
    parser.add_argument(
        '-N', '--samples', type=int, default=10000,
        help='Number of samples for the simulation (default: 10000)')
    parser.add_argument(
        '--seed', type=int, default=None,
        help='Random seed for reproducibility (default: None)')
    parser.add_argument(
        '-T', '--tight', action='store_true',
        help='Use tight layout for the plots (default: False)')

    args = parser.parse_args()
    simplot(
        args.samples,
        seed=args.seed,
        tight=args.tight
    )

if __name__ == '__main__':
    main()
