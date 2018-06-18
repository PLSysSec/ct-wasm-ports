WASMS = salsa20.O0.wasm salsa20.O2.wasm
WATS = $(WASMS:.wasm=.wat)

default: compile $(WATS)

%.wat: %.wasm
	wasm-dis $< -o $@

compile: $(WASMS)

salsa20.O%.wasm: salsa20.c
	emcc -O$* -s WASM=1 -s SIDE_MODULE=1 -s INCLUDE_FUNCTIONS=1 -o $@ $<

bench: $(WASMS)
	ct-node benchmark.js

tests: $(WASMS)
	ct-node stack.js

clean:
	rm *.wasm *.wat
