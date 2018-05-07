%.wasm: %.wat
	../../../ct-wasm-spec/interpreter/wasm -d -i $< -o ./$@

WATS = $(wildcard ./*.wat)
WASMS = $(WATS:.wat=.wasm)

run: $(WASMS)
	../../../ct-wasm-node/node main.js

clean:
	rm *.wasm
