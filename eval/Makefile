# Setup Variables
EVAL_DIR:=$(shell dirname $(realpath $(lastword $(MAKEFILE_LIST))))
ROOT_DIR:=$(shell git rev-parse --show-toplevel)
RESULTS_DIR:=$(EVAL_DIR)/results
TMPDIR:=$(shell mktemp -d)

# Only used to resolve the CT_NODE_PATH and VN_NODE_PATH executables
# if you manually set the environment variables, these vars don't matter
CT_NODE_REPO:="https://github.com/PLSysSec/ct-wasm-node.git"
VN_NODE_HASH:="7c73cd4c70513dd4fa1f7ea13e3bb3270696eabe"

CT_SPEC_REPO:="https://github.com/PLSysSec/ct-wasm-spec.git"

# You probably shouldn't touch these unless you're testing
CT_NODE_PATH:=$(EVAL_DIR)/.repos/ct-wasm-node/out/Release/node
VN_NODE_PATH:=$(EVAL_DIR)/.repos/node/out/Release/node
CT_SPEC_PATH:=$(EVAL_DIR)/.repos/ct-wasm-spec/interpreter/wasm

SUMMARY_FILE:=$(RESULTS_DIR)/summary.txt

# Manifest
default: $(SUMMARY_FILE) $(RESULTS_DIR)/validation_timing.csv

# Summary
$(SUMMARY_FILE): $(CT_NODE_PATH)
	if [[ "$$OSTYPE" == "linux"* ]]; then \
        echo "Linux" > $(SUMMARY_FILE) ; \
		lscpu >> $(SUMMARY_FILE) ; \
	elif [[ "$$OSTYPE" == "darwin"* ]]; then \
        echo "MacOS" > $(SUMMARY_FILE) ; \
		system_profiler SPHardwareDataType >> $(SUMMARY_FILE) ; \
	else \
		echo "Unknown System" > $(SUMMARY_FILE); \
	fi

	echo -e "\n\nCT Node Commit: " >> $(SUMMARY_FILE)
	git --git-dir=$(EVAL_DIR)/.repos/ct-wasm-node/.git log -n 1 HEAD >> $(SUMMARY_FILE)

	echo -e "\n\nVanilla Node Commit: " >> $(SUMMARY_FILE)
	git --git-dir=$(EVAL_DIR)/.repos/ct-wasm-node/.git log -n 1 $(VN_NODE_HASH) >> $(SUMMARY_FILE)

# Validation timing
VAL_TRIALS:=100000
SALSA_20_PUB:=$(ROOT_DIR)/salsa20/ct/pub_salsa20_stack.wasm
SALSA_20_SEC:=$(ROOT_DIR)/salsa20/ct/sec_salsa20_stack.wasm
VAL_TESTS:=$(SALSA_20_PUB) $(SALSA_20_SEC)

$(RESULTS_DIR)/validation_timing.csv: $(CT_NODE_PATH) $(VN_NODE_PATH) $(VAL_TESTS)
	echo -e "\n\nVALIDATION TIMING\n" >> $(SUMMARY_FILE)
	echo "Trials: $(VAL_TRIALS)" >> $(SUMMARY_FILE)

	cat /dev/null > $(TMPDIR)/names.column
	for file in $(VAL_TESTS) ; do \
		echo `basename $$file` >> $(TMPDIR)/names.column ; \
		echo `basename $$file` >> $(SUMMARY_FILE) ; \
	done
	$(CT_NODE_PATH) $(EVAL_DIR)/validation_timing/bench.js $(VAL_TRIALS) $(VAL_TESTS) > $(TMPDIR)/validation_ct.column
	$(VN_NODE_PATH) $(EVAL_DIR)/validation_timing/bench.js $(VAL_TRIALS) $(VAL_TESTS) > $(TMPDIR)/validation_vn.column

	echo 'test\tCT\tvanilla' > $(RESULTS_DIR)/validation_timing.csv
	paste $(TMPDIR)/names.column $(TMPDIR)/validation_ct.column $(TMPDIR)/validation_vn.column >> $(RESULTS_DIR)/validation_timing.csv




# ------- Plumbing ---------
$(EVAL_DIR)/.repos/ct-wasm-node/Makefile:
	git clone $(CT_NODE_REPO) $(EVAL_DIR)/.repos/ct-wasm-node

$(EVAL_DIR)/.repos/ct-wasm-node/out/Release/node: $(EVAL_DIR)/.repos/ct-wasm-node/Makefile
	$(EVAL_DIR)/.repos/ct-wasm-node/configure
	$(MAKE) -j -C $(EVAL_DIR)/.repos/ct-wasm-node

$(EVAL_DIR)/.repos/node/Makefile: $(EVAL_DIR)/.repos/ct-wasm-node/Makefile
	mkdir -p $(EVAL_DIR)/.repos/node
	git --git-dir=$(EVAL_DIR)/.repos/ct-wasm-node/.git --work-tree=$(EVAL_DIR)/.repos/node/ checkout $(VN_NODE_HASH) -f -q -- ./

$(EVAL_DIR)/.repos/node/out/Release/node: $(EVAL_DIR)/.repos/node/Makefile
	$(EVAL_DIR)/.repos/node/configure
	$(MAKE) -j -C $(EVAL_DIR)/.repos/node

$(EVAL_DIR)/.repos/ct-wasm-spec/interpreter/Makefile:
	git clone $(CT_SPEC_REPO) $(EVAL_DIR)/.repos/ct-wasm-spec

$(EVAL_DIR)/.repos/ct-wasm-spec/interpreter/wasm: $(EVAL_DIR)/.repos/ct-wasm-spec/interpreter/Makefile
	$(MAKE) -C $(EVAL_DIR)/.repos/ct-wasm-spec/interpreter

%.wasm: %.wat $(CT_SPEC_PATH)
	$(CT_SPEC_PATH) -d -i $< -o $@
