#!/bin/bash

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
