for nod in ct-node node; do
  for nacl in ctwasm ctwasm-strip vanilla; do
    echo "$nod $nacl"
    if [ ! -f ./${nod}-${nacl}.bench ]; then
      $nod $HOME/ct-wasm/ct-wasm-ports/eval/tweetnacl-$nacl/src/test_node.js > ./${nod}-${nacl}.bench
    fi
  done ;
done
