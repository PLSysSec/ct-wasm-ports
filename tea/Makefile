WASMS = tea.O0.wasm tea.O2.wasm
WATS = $(WASMS:.wasm=.wat)

default: compile $(WATS)

%.wat: %.wasm
	wasm-dis $< -o $@

compile: $(WASMS)

tea.O%.wasm: ref.c
	emcc -O$* -s WASM=1 -s SIDE_MODULE=1 -s INCLUDE_FUNCTIONS=1 -o $@ $<
