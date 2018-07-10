for nod in ct-node node; do
  for nacl in ctwasm ctwasm-strip vanilla; do
    echo "$nod $nacl"
    if [ ! -f ./${nod}-${nacl}.bench ]; then
      $nod $HOME/ct-wasm/ct-wasm-ports/eval/node_tweetnacl/test.js tn_${nacl}.wasm > ./${nod}-${nacl}.bench
    fi
  done ;
done
