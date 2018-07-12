#!/usr/bin/env python3

import sys
import numpy as np
from os.path import basename

files = sys.argv[1:]
first = True
print(','.join([basename(fname).split('.')[0] for fname in files]))
for fname in files:
    with open(fname) as f:
        lines = f.readlines()

    ls = (l.strip() for l in lines)
    ls = [int(l, 16) for l in lines]

    d = np.diff(ls)
    if first:
        first = False
    else:
        print(',', end='')
    print(np.median(d), end='')
print('')
