#!/usr/bin/env python3

import sys
import numpy as np

for fname in sys.argv[1:]:
    with open(fname) as f:
        lines = f.readlines()

    ls = (l.strip() for l in lines)
    ls = [int(l, 16) for l in lines]

    d = np.diff(ls)
    print(fname.split('.')[0], np.median(d), sep='\t')
