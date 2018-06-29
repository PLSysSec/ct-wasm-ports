%.wasm: %.wat
	wasm -d -i $< -o $@

WATS = $(wildcard ./*.wat)
WASMS = $(WATS:.wat=.wasm)

default: run

run: $(WASMS)
	ct-node bench.js
	./median.py *.measurements

clean:
	rm -f *.measurements
	rm -f *.wasm
