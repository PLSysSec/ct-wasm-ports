%.wasm: %.wat
	wasm -d -i $< -o $@

WATS = $(wildcard ./*.wat)
WASMS = $(WATS:.wat=.wasm)

default:	run

run: $(WASMS)
	ct-node main.js

bench: $(WASMS)
	-mkdir output
	ct-node benchmark.js

tests: $(WASMS)
	ct-node stack.js

clean:
	-rm *.wasm
