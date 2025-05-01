#!/usr/bin/env python

import matplotlib.pyplot as pp
import numpy as np

# Define lambda range and function
lambdas = np.linspace(0, 1, 1000)
f = 12 * lambdas * (1 - lambdas)**2

# Create the plot
pp.plot(lambdas, f, label=r'$12\,\lambda\,(1-\lambda)^2$')
pp.title('Plot of f(λ) = 12λ(1−λ)²')
pp.xlabel(r'λ')
pp.ylabel('f(λ)')
pp.legend()
pp.grid(True)
pp.show()
