%.wasm: %.wat
	wasm -d -i $< -o ./$@

WATS = $(wildcard ./*.wat)
WASMS = $(WATS:.wat=.wasm)

run: $(WASMS)
	ct-node main.js

clean:
	rm *.wasm
