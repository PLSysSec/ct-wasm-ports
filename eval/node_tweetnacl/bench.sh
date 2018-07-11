#! /usr/bin/env bash
DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

for nacl in ctwasm ctwasm-strip vanilla; do
  $2 $DIR/test.js $DIR/tn_${nacl}.wasm > $1/ct-node-${nacl}.bench
done ;

for nacl in ctwasm ctwasm-strip vanilla; do
  $3 $DIR/test.js $DIR/tn_${nacl}.wasm &> $1/node-${nacl}.bench
done ;
