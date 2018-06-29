WASMS = sha256.O0.wasm sha256.O2.wasm
WATS = $(WASMS:.wasm=.wat)

default: compile $(WATS)

%.wat: %.wasm
	wasm-dis $< -o $@

compile: $(WASMS)

sha256.O%.wasm: sha256.c
	emcc -O$* -s WASM=1 -s SIDE_MODULE=1 -s INCLUDE_FUNCTIONS=1 -o $@ $<
