#!/bin/bash
set -e

if [[ $# < 1 ]]; then
  echo "USAGE: ./dobench.sh <bench_*.js> [--stripped]" >&2
  exit 1
fi
if [[ ! -f "$1" ]]; then
  echo "JS harness $1 must exist" >&2
  exit 1
fi

arg=""
node="ct-node"
outfile="$1"
outfile=${outfile#bench_}
outfile=${outfile%.js}

if [[ "$2" = "--stripped" ]]; then
  outfile=${outfile}_stripped
  arg="--stripped"
  node="node"
fi

outfile=${outfile}.txt

echo dudect_reader "$node $1 $arg" \> dudect_results/$outfile
stdbuf -oL dudect_reader "$node $1 $arg" | tee dudect_results/$outfile
