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

TWEETNACL_REPO:="git@github.com:PLSysSec/tweetnacl-ctwasm.git"

# You probably shouldn't touch these unless you're testing
CT_NODE_PATH:=$(EVAL_DIR)/.repos/ct-wasm-node/out/Release/node
VN_NODE_PATH:=$(EVAL_DIR)/.repos/node/out/Release/node
CT_SPEC_PATH:=$(EVAL_DIR)/.repos/ct-wasm-spec/interpreter/wasm

SUMMARY_FILE:=$(RESULTS_DIR)/summary.txt

# Manifest
default: $(SUMMARY_FILE) $(RESULTS_DIR)/validation_timing.csv $(RESULTS_DIR)/tweetnacl_size.csv

# Don't do this unless you want to rebuild node... twice...
superclean: clean
	rm -rf $(EVAL_DIR)/.repos

clean:
	rm $(EVAL_DIR)/results/*

# Summary
$(SUMMARY_FILE): $(CT_NODE_PATH) | $(EVAL_DIR)/.repos/tweet-nacl
	if [[ "$$OSTYPE" == "linux"* ]]; then \
        echo "Linux" > $(SUMMARY_FILE) ; \
		lscpu >> $(SUMMARY_FILE) ; \
	elif [[ "$$OSTYPE" == "darwin"* ]]; then \
        echo "MacOS" > $(SUMMARY_FILE) ; \
		system_profiler SPHardwareDataType >> $(SUMMARY_FILE) ; \
	else \
		echo "Unknown System" > $(SUMMARY_FILE); \
	fi

	printf "\n\nCT Node Commit: \n" >> $(SUMMARY_FILE)
	git --git-dir=$(EVAL_DIR)/.repos/ct-wasm-node/.git log -n 1 HEAD >> $(SUMMARY_FILE)

	printf "\n\nVanilla Node Commit: \n" >> $(SUMMARY_FILE)
	git --git-dir=$(EVAL_DIR)/.repos/ct-wasm-node/.git log -n 1 $(VN_NODE_HASH) >> $(SUMMARY_FILE)

	printf "\n\nTweetNacl Commit: \n" >> $(SUMMARY_FILE)
	git --git-dir=$(EVAL_DIR)/.repos/tweet-nacl/.git log -n 1 HEAD >> $(SUMMARY_FILE)

# Validation timing
VAL_TRIALS:=100000
SALSA_20_PUB:=$(ROOT_DIR)/salsa20/ct/pub_salsa20_stack.wasm
SALSA_20_SEC:=$(ROOT_DIR)/salsa20/ct/sec_salsa20_stack.wasm
VAL_SUMMARY:=$(RESULTS_DIR)/validation_timing.txt
VAL_TESTS:=$(SALSA_20_PUB) $(SALSA_20_SEC)

$(RESULTS_DIR)/validation_timing.csv: $(CT_NODE_PATH) $(VN_NODE_PATH) $(VAL_TESTS)
	echo "VALIDATION TIMING\n" >> $(VAL_SUMMARY)
	echo "Trials: $(VAL_TRIALS)" >> $(VAL_SUMMARY)

	cat /dev/null > $(TMPDIR)/names.column
	for file in $(VAL_TESTS) ; do \
		echo `basename $$file` >> $(TMPDIR)/names.column ; \
		echo `basename $$file` >> $(VAL_SUMMARY) ; \
	done
	$(CT_NODE_PATH) $(EVAL_DIR)/validation_timing/bench.js $(VAL_TRIALS) $(VAL_TESTS) > $(TMPDIR)/validation_ct.column
	$(VN_NODE_PATH) $(EVAL_DIR)/validation_timing/bench.js $(VAL_TRIALS) $(VAL_TESTS) > $(TMPDIR)/validation_vn.column

	printf 'test\tCT(ms)\tVanilla(ms)\n' > $(RESULTS_DIR)/validation_timing.csv
	paste $(TMPDIR)/names.column $(TMPDIR)/validation_ct.column $(TMPDIR)/validation_vn.column >> $(RESULTS_DIR)/validation_timing.csv


# Byte-code Sizes
PUB_NACL_WASM=$(EVAL_DIR)/.repos/tweet-nacl/a.wasm
SEC_NACL=$(EVAL_DIR)/.repos/tweet-nacl/sec_nacl

$(RESULTS_DIR)/tweetnacl_size.csv : $(SEC_NACL).wasm
	printf 'version\tsize (bytes)\n' > $@
	printf 'public\t' >> $@
	ls -l $(PUB_NACL_WASM) | awk '{sum = sum + $$5} END {print sum}' >> $@
	printf 'secret\t' >> $@
	ls -l $< | awk '{sum = sum + $$5} END {print sum}' >> $@

$(SEC_NACL).wat: | $(EVAL_DIR)/.repos/tweet-nacl
	echo '(module (import "js" "mem" (memory secret 1))' > $@
	for file in `ls $(EVAL_DIR)/.repos/tweet-nacl/src/wat` ; do \
		cat $(EVAL_DIR)/.repos/tweet-nacl/src/wat/$$file >> $@ ; \
	done
	echo ')' >> $@



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

$(EVAL_DIR)/.repos/tweet-nacl:
	git clone $(TWEETNACL_REPO) $(EVAL_DIR)/.repos/tweet-nacl

%.wasm: %.wat $(CT_SPEC_PATH)
	$(CT_SPEC_PATH) -d -u -i $< -o $@
