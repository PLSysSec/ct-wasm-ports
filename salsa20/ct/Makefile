%.wasm: %.wat
	../../../ct-wasm-spec/interpreter/wasm -d -i $< -o $@

WATS = $(wildcard ./*.wat)
WASMS = $(WATS:.wat=.wasm)

default:	test

test: $(WASMS)
	../../../ct-wasm-node/node main.js

bench: $(WASMS)
	../../../ct-wasm-node/node benchmark.js

clean:
	rm *.wasm
