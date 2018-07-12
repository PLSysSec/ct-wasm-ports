#! /usr/bin/env bash
DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

for nacl in ctwasm stripped-wasm wasm; do
  $2 $DIR/test.js $DIR/nacl-${nacl}.js > $1/ct-node-${nacl}.bench
done ;

for nacl in ctwasm stripped-wasm wasm; do
  $3 $DIR/test.js $DIR/nacl-${nacl}.js > $1/node-${nacl}.bench
done ;
