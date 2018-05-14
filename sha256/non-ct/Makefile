WASM ?= wasm
CTNODE ?= ct-node

%.wasm: %.wat
	$(WASM) -d -i $< -o ./$@

WATS = $(wildcard ./*.wat)
WASMS = $(WATS:.wat=.wasm)

run: $(WASMS)
	$(CTNODE) main.js

clean:
	rm *.wasm
