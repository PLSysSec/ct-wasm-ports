#!/usr/bin/env python3
import sys
import re
import numpy as np
import os
from tempfile import mkdtemp
from os.path import basename

node_files = ['ct-node-ctwasm.bench',
  'ct-node-vanilla.bench',
  'ct-node-ctwasm-strip.bench',
  'node-ctwasm.bench',
  'node-vanilla.bench',
  'node-ctwasm-strip.bench']

num_dir = int(sys.argv[2])
logTests = True
testList = []
tmpdir = mkdtemp()

for config in node_files:
  first = True
  bname = basename(config).split('.')[0]
  wasmArr = np.empty([32, num_dir])
  jsArr = np.empty([32, num_dir])
  for curdir in range(1, 1 + num_dir):
    fname = sys.argv[1] + '/' + str(curdir) + '/' + config

    with open(fname) as f:
      i = 0
      for line in f:
        test = re.search(r'[a-z]+(\_[a-z]+)+[0-9]*(\_[a-z]+)*', line)
        wasmNum = re.search(r'wasm:\s[0-9]+(\.[0-9]+)*', line)
        jsNum = re.search(r'js:\s[0-9]+(\.[0-9]+)*', line)
        if test: 
          first = False
          wasmNum = re.search(r'[0-9]+(\.[0-9]+)*', wasmNum.group()).group()
          jsNum = re.search(r'[0-9]+(\.[0-9]+)*', jsNum.group()).group()
          wasmArr[i, curdir - 1] = wasmNum
          jsArr[i, curdir - 1] = jsNum
          i = i + 1
          if logTests:
            testList.append(test.group())

    logTests = False

  wasmSummary = open(tmpdir + '/' + bname + '.csv', 'w')
  jsSummary = open(tmpdir + '/' + bname + '_js.csv', 'w')
  
  for i in range(0, 32):
    if config == node_files[3]:
      wasmSummary.write('\n')
      jsSummary.write('\n')
      continue
    wasmMed = np.median(wasmArr[i])
    jsMed = np.median(jsArr[i])
    wasmSummary.write(str(wasmMed) + '\n')
    jsSummary.write(str(jsMed) + '\n')
  
  wasmSummary.close()
  jsSummary.close()

results = ['ct-node-ctwasm.csv',
  'ct-node-vanilla.csv',
  'ct-node-ctwasm-strip.csv',
  'node-ctwasm.csv',
  'node-vanilla.csv',
  'node-ctwasm-strip.csv']

overall = sys.stdout
overall.write('Test, CT-CT, CT-VN, CT-ST, VN-CT, VN-VN, VN-ST\n')

for i in range(0, 32):
  overall.write(testList[i] + ',')
  for res in results:
    f = open(tmpdir + '/' + res, 'r')
    lines = f.readlines()
    for j in range(0, 32):
      if j == i:
        stripped = lines[j].strip()
        overall.write(stripped)
    if res == results[5]: 
      overall.write('\n')
    else:
      overall.write(',')
    f.close()
