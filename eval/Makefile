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
TWEETNACL_PUB_HASH:="ae80d0cccbf6ffbe6a04444f6de3ab18a1b657a1"

# You probably shouldn't touch these unless you're testing
CT_NODE_PATH:=$(EVAL_DIR)/.repos/ct-wasm-node/out/Release/node
VN_NODE_PATH:=$(EVAL_DIR)/.repos/node/out/Release/node
CT_SPEC_PATH:=$(EVAL_DIR)/.repos/ct-wasm-spec/interpreter/wasm
CT_REWRITE_PATH:=$(EVAL_DIR)/.repos/ct-wasm-spec/interpreter/ctrewrite

SUMMARY_FILE:=$(RESULTS_DIR)/summary.txt

# Manifest
default: $(SUMMARY_FILE) $(RESULTS_DIR)/validation_timing.csv $(RESULTS_DIR)/tweetnacl_size.csv $(RESULTS_DIR)/crypto_benchmarks.csv

# Don't do this unless you want to rebuild node... twice...
superclean: clean
	rm -rf $(EVAL_DIR)/.repos

clean:
	rm $(EVAL_DIR)/results/*

# Summary
$(SUMMARY_FILE): $(CT_NODE_PATH) | $(EVAL_DIR)/.repos/tweet-nacl $(EVAL_DIR)/.repos/tweet-nacl-pub
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

	printf "\n\nTweetNacl Sec Commit: \n" >> $(SUMMARY_FILE)
	git --git-dir=$(EVAL_DIR)/.repos/tweet-nacl/.git log -n 1 HEAD >> $(SUMMARY_FILE)

	printf "\n\nTweetNacl Pub Commit: \n" >> $(SUMMARY_FILE)
	git --git-dir=$(EVAL_DIR)/.repos/tweet-nacl/.git log -n 1 $(TWEETNACL_PUB_HASH) >> $(SUMMARY_FILE)

# Byte-code Sizes
PUB_NACL=$(EVAL_DIR)/.repos/tweet-nacl-pub/pub_nacl
SEC_NACL=$(EVAL_DIR)/.repos/tweet-nacl/sec_nacl

$(RESULTS_DIR)/tweetnacl_size.csv : $(SEC_NACL).wasm $(PUB_NACL).wasm
	printf 'version,size (bytes)\n' > $@
	printf 'public,' >> $@
	ls -l $(PUB_NACL).wasm | awk '{sum = sum + $$5} END {print sum}' >> $@
	printf 'secret,' >> $@
	ls -l $< | awk '{sum = sum + $$5} END {print sum}' >> $@

$(SEC_NACL).wat: | $(EVAL_DIR)/.repos/tweet-nacl
	echo '(module (import "js" "mem" (memory secret 1))' > $@
	for file in `ls $(EVAL_DIR)/.repos/tweet-nacl/src/wat` ; do \
		cat $(EVAL_DIR)/.repos/tweet-nacl/src/wat/$$file >> $@ ; \
	done
	echo ')' >> $@

$(PUB_NACL).wat: | $(EVAL_DIR)/.repos/tweet-nacl-pub
	echo '(module (import "js" "mem" (memory 1))' > $@
	for file in `ls $(EVAL_DIR)/.repos/tweet-nacl-pub/src/wat` ; do \
		cat $(EVAL_DIR)/.repos/tweet-nacl-pub/src/wat/$$file >> $@ ; \
	done
	echo ')' >> $@

# Validation timing
VAL_TRIALS:=10000
SALSA_20_PUB:=$(EVAL_DIR)/crypto_benchmarks/salsa20/pub_salsa20.wasm
SALSA_20_SEC:=$(EVAL_DIR)/crypto_benchmarks/salsa20/sec_salsa20.wasm
VAL_SUMMARY:=$(RESULTS_DIR)/validation_timing.txt
VAL_TESTS:=$(SALSA_20_PUB) $(SALSA_20_SEC) $(PUB_NACL).wasm $(SEC_NACL).wasm

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

	printf 'test,CT(ms),Vanilla(ms)\n' > $(RESULTS_DIR)/validation_timing.csv
	paste -d , $(TMPDIR)/names.column $(TMPDIR)/validation_ct.column $(TMPDIR)/validation_vn.column >> $(RESULTS_DIR)/validation_timing.csv


# Crypto Benchmarks
CB_DIR:=$(EVAL_DIR)/crypto_benchmarks
ALGOS:=salsa20 sha256 tea
CRYPTO_WATS = $(shell find crypto_benchmarks -type f -name '*.wat')
CRYPTO_WASMS = $(CRYPTO_WATS:.wat=.wasm)
VARIANTS:=hand,handpub,js
$(RESULTS_DIR)/crypto_benchmarks.csv: $(CT_NODE_PATH) $(CB_DIR) $(CRYPTO_WASMS)
	echo '$(CRYPTO_WASMS)'
	printf "algo,hand,handpub,js\n" > $@
	npm install $(CB_DIR)
	for algo in $(ALGOS) ; do \
		mkdir -p $(TMPDIR)/$$algo ; \
		$(CT_NODE_PATH) $(CB_DIR)/$$algo.js $(TMPDIR)/$$algo ; \
		$(CB_DIR)/median.py $(TMPDIR)/$$algo/{$(VARIANTS)}.measurements > $(TMPDIR)/$$algo.row ; \
		printf "$$algo," >> $@ ; \
		sed -n 2p $(TMPDIR)/$$algo.row >> $@ ; \
	done

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

$(CT_REWRITE_PATH): $(EVAL_DIR)/.repos/ct-wasm-spec/interpreter/Makefile
	$(MAKE) -C $(EVAL_DIR)/.repos/ct-wasm-spec/interpreter ctrewrite

$(EVAL_DIR)/.repos/tweet-nacl:
	git clone $(TWEETNACL_REPO) $(EVAL_DIR)/.repos/tweet-nacl

$(EVAL_DIR)/.repos/tweet-nacl-pub: | $(EVAL_DIR)/.repos/tweet-nacl
	mkdir -p $@
	git --git-dir=$(EVAL_DIR)/.repos/tweet-nacl/.git --work-tree=$@/ checkout $(TWEETNACL_PUB_HASH) -f -q -- ./

%.wasm: %.wat $(CT_SPEC_PATH)
	$(CT_SPEC_PATH) -d -u -i $< -o $@

.SECONDARY: %.wasm
