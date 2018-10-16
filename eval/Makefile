.NOTPARALLEL:

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

DUDECT_REPO:="https://github.com/PLSysSec/dudect.git"
DUDECT_HASH:="362e3d0cb7a0199a3cca435772122eb17dc12799"

# You probably shouldn't touch these unless you're testing
CT_NODE_PATH:=$(EVAL_DIR)/.repos/ct-wasm-node/out/Release/node
VN_NODE_PATH:=$(EVAL_DIR)/.repos/node/out/Release/node
CT_SPEC_PATH:=$(EVAL_DIR)/.repos/ct-wasm-spec/interpreter/wasm
CT_REWRITE_PATH:=$(EVAL_DIR)/.repos/ct-wasm-spec/interpreter/ctrewrite
DUDECT_PATH:=$(EVAL_DIR)/.repos/dudect/dudect_reader_-O2

SUMMARY_FILE:=$(RESULTS_DIR)/summary.txt

.PHONY: tools ct_node ct_wasm_spec ct2wasm eval

ct_node: $(CT_NODE_PATH)
	cp $(CT_NODE_PATH) $(EVAL_DIR)/tools/$@

ct_wasm_spec: $(CT_SPEC_PATH)
	cp $(CT_SPEC_PATH) $(EVAL_DIR)/tools/$@

ct2wasm: $(CT_REWRITE_PATH)
	cp $(CT_REWRITE_PATH) $(EVAL_DIR)/tools/$@

tools: ct_node ct_wasm_spec ct2wasm;


default: tools;

# Manifest
eval: $(SUMMARY_FILE) $(RESULTS_DIR)/validation_timing.csv $(RESULTS_DIR)/file_sizes.csv $(RESULTS_DIR)/crypto_benchmarks.csv;

# Don't do this unless you want to rebuild node... twice...
superclean: clean
	rm -f $(EVAL_DIR)/tools/*
	rm -rf $(EVAL_DIR)/.repos

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


PUB_NACL:=$(EVAL_DIR)/node_tweetnacl/tn_vanilla
SEC_NACL:=$(EVAL_DIR)/node_tweetnacl/tn_ctwasm

# Validation timing
VAL_TRIALS:=10000
SALSA_20_PUB:=$(EVAL_DIR)/crypto_benchmarks/salsa20/pub_salsa20.wasm
SALSA_20_SEC:=$(EVAL_DIR)/crypto_benchmarks/salsa20/sec_salsa20.wasm
VAL_SUMMARY:=$(RESULTS_DIR)/validation_timing.txt
VAL_PUBS:=$(SALSA_20_PUB) $(EVAL_DIR)/crypto_benchmarks/sha256/pub_sha256.wasm $(EVAL_DIR)/crypto_benchmarks/tea/pub_tea.wasm $(PUB_NACL).wasm
VAL_SEC:=$(SALSA_20_SEC) $(EVAL_DIR)/crypto_benchmarks/sha256/sec_sha256.wasm $(EVAL_DIR)/crypto_benchmarks/tea/sec_tea.wasm 
VAL_STRIP:=$(EVAL_DIR)/crypto_benchmarks/salsa20/strip_salsa20.wasm $(EVAL_DIR)/crypto_benchmarks/sha256/strip_sha256.wasm $(EVAL_DIR)/crypto_benchmarks/tea/strip_tea.wasm 
VAL_TESTS:=$(VAL_PUBS) $(VAL_SEC) $(VAL_STRIP) $(SEC_NACL).wasm $(EVAL_DIR)/node_tweetnacl/tn_ctwasm-strip.wasm $(EVAL_DIR)/node_tweetnacl/tn_ctwasm_sign_open-strip.wasm $(EVAL_DIR)/node_tweetnacl/tn_ctwasm_sign_open.wasm
validation: $(RESULTS_DIR)/validation_timing.csv;
$(RESULTS_DIR)/validation_timing.csv: $(CT_NODE_PATH) $(VN_NODE_PATH) $(VAL_TESTS)
	echo "VALIDATION TIMING\n" >> $(VAL_SUMMARY)
	echo "Trials: $(VAL_TRIALS)" >> $(VAL_SUMMARY)

	cat /dev/null > $(TMPDIR)/names.column
	for file in Salsa20 SHA-256 TEA TweetNacl ; do \
		echo `basename $$file` >> $(TMPDIR)/names.column ; \
		echo `basename $$file` >> $(VAL_SUMMARY) ; \
	done
	$(CT_NODE_PATH) $(EVAL_DIR)/validation_timing/bench.js $(VAL_TRIALS) $(VAL_SEC) > $(TMPDIR)/validation_ct_sec.column
	echo `$(CT_NODE_PATH) $(EVAL_DIR)/validation_timing/bench.js $(VAL_TRIALS) $(EVAL_DIR)/node_tweetnacl/tn_ctwasm_sign_open.wasm` + \
		    `$(CT_NODE_PATH) $(EVAL_DIR)/validation_timing/bench.js $(VAL_TRIALS) $(SEC_NACL).wasm` | bc >> $(TMPDIR)/validation_ct_sec.column
	$(CT_NODE_PATH) $(EVAL_DIR)/validation_timing/bench.js $(VAL_TRIALS) $(VAL_PUBS) > $(TMPDIR)/validation_ct_pub.column
	$(CT_NODE_PATH) $(EVAL_DIR)/validation_timing/bench.js $(VAL_TRIALS) $(VAL_STRIP) > $(TMPDIR)/validation_ct_strip.column
	echo `$(CT_NODE_PATH) $(EVAL_DIR)/validation_timing/bench.js $(VAL_TRIALS) $(EVAL_DIR)/node_tweetnacl/tn_ctwasm_sign_open-strip.wasm` + \
		    `$(CT_NODE_PATH) $(EVAL_DIR)/validation_timing/bench.js $(VAL_TRIALS) $(EVAL_DIR)/node_tweetnacl/tn_ctwasm-strip.wasm` | bc >> $(TMPDIR)/validation_ct_strip.column
	$(VN_NODE_PATH) $(EVAL_DIR)/validation_timing/bench.js $(VAL_TRIALS) $(VAL_PUBS) > $(TMPDIR)/validation_vn_pub.column
	$(VN_NODE_PATH) $(EVAL_DIR)/validation_timing/bench.js $(VAL_TRIALS) $(VAL_STRIP) > $(TMPDIR)/validation_vn_strip.column
	echo `$(VN_NODE_PATH) $(EVAL_DIR)/validation_timing/bench.js $(VAL_TRIALS) $(EVAL_DIR)/node_tweetnacl/tn_ctwasm_sign_open-strip.wasm` + \
		    `$(VN_NODE_PATH) $(EVAL_DIR)/validation_timing/bench.js $(VAL_TRIALS) $(EVAL_DIR)/node_tweetnacl/tn_ctwasm-strip.wasm` | bc >> $(TMPDIR)/validation_vn_strip.column

	printf 'test,ctsec,ctpub,ctstrip,vnpub,vnstrip\n' > $(RESULTS_DIR)/validation_timing.csv
	paste -d , $(TMPDIR)/names.column $(TMPDIR)/validation_ct_sec.column $(TMPDIR)/validation_ct_pub.column $(TMPDIR)/validation_ct_strip.column \
	                                  $(TMPDIR)/validation_vn_pub.column $(TMPDIR)/validation_vn_strip.column \
									  >> $(RESULTS_DIR)/validation_timing.csv


# Byte-code Sizes
SEC_NACL_PUBMODULE=$(EVAL_DIR)/.repos/tweet-nacl/sec_nacl_sign_open

bytecode_sizes: $(RESULTS_DIR)/file_sizes.csv;
$(RESULTS_DIR)/file_sizes.csv: $(SEC_NACL).wasm $(PUB_NACL).wasm
	cat /dev/null > $(TMPDIR)/bs_names.column
	for file in Salsa20 SHA-256 TEA TweetNacl ; do \
		echo `basename $$file` >> $(TMPDIR)/bs_names.column ; \
	done

	ls -l $(VAL_SEC) | awk '{print $$5}' > $(TMPDIR)/bs_sec.column
	ls -l $(SEC_NACL).wasm $(EVAL_DIR)/node_tweetnacl/tn_ctwasm_sign_open.wasm | awk '{sum = sum + $$5} END {print sum}' >> $(TMPDIR)/bs_sec.column
	ls -l $(VAL_PUBS) | awk '{print $$5}' > $(TMPDIR)/bs_pub.column
	ls -l $(VAL_STRIP) | awk '{print $$5}' > $(TMPDIR)/bs_strip.column
	ls -l $(EVAL_DIR)/node_tweetnacl/tn_ctwasm-strip.wasm $(EVAL_DIR)/node_tweetnacl/tn_ctwasm_sign_open-strip.wasm | awk '{sum = sum + $$5} END {print sum}' >> $(TMPDIR)/bs_strip.column

	printf 'mod,sec,pub,strip\n' > $@
	paste -d , $(TMPDIR)/bs_names.column $(TMPDIR)/bs_sec.column $(TMPDIR)/bs_pub.column $(TMPDIR)/bs_strip.column >> $@

# Crypto Benchmarks
CB_DIR:=$(EVAL_DIR)/crypto_benchmarks
ALGOS:=salsa20 sha256 tea
CRYPTO_WATS = $(shell find crypto_benchmarks -type f -name '*.wat')
CRYPTO_WASMS = $(CRYPTO_WATS:.wat=.wasm)
VARIANTS:=hand,handpub,js
runtimes: $(RESULTS_DIR)/crypto_benchmarks.csv;
$(RESULTS_DIR)/crypto_benchmarks.csv: $(CT_NODE_PATH) $(CB_DIR) $(CRYPTO_WASMS)
	echo '$(CRYPTO_WASMS)'
	printf "algo,hand,handpub,js\n" > $@
	npm install --prefix $(CB_DIR)
	for algo in $(ALGOS) ; do \
		mkdir -p $(TMPDIR)/$$algo ; \
		$(CT_NODE_PATH) $(CB_DIR)/$$algo.js $(TMPDIR)/$$algo ; \
		$(CB_DIR)/median.py $(TMPDIR)/$$algo/{$(VARIANTS)}.measurements > $(TMPDIR)/$$algo.row ; \
		printf "$$algo," >> $@ ; \
		sed -n 2p $(TMPDIR)/$$algo.row >> $@ ; \
	done

# TweetNacl Node
TWEET_WATS:=$(wildcard $(EVAL_DIR)/node_tweetnacl/*.wat)
TWEET_WASMS:=$(TWEET_WATS:%.wat=%.wasm)
TWEET_TRIALS:=10
tweetnacl: $(RESULTS_DIR)/node_tweetnacl.csv
.PHONY: tweetnacl

$(RESULTS_DIR)/node_tweetnacl.csv: $(CT_NODE_PATH) $(VN_NODE_PATH) $(TWEET_WASMS)
	npm install --prefix $(EVAL_DIR)/node_tweetnacl
	for i in $$(seq 1 $(TWEET_TRIALS)) ; do \
		mkdir -p $(TMPDIR)/$$i ; \
		echo "TweetNacl Trial $$i / $(TWEET_TRIALS)" ; \
		$(EVAL_DIR)/node_tweetnacl/bench.sh $(TMPDIR)/$$i $(CT_NODE_PATH) $(VN_NODE_PATH) ; \
	done

	$(EVAL_DIR)/node_tweetnacl/aggregate.py $(TMPDIR) $(TWEET_TRIALS) > $@

clean:
	rm -rf $(EVAL_DIR)/results/*
	rm -f $(EVAL_DIR)/node_tweetnacl/*.wasm
	rm -f $(CB_DIR)/**/*.wasm

# DUDECT Stuff
DUDE_SCRIPTS:=$(wildcard $(EVAL_DIR)/dudect/bench*.js)
DUDE_RESULTS:=$(patsubst bench_%.js, $(RESULTS_DIR)/dudect/%.txt, $(notdir $(DUDE_SCRIPTS)))
DUDE_WASMS:=$(TWEET_WASMS) $(CRYPTO_WASMS)
DUDE_TIMEOUT ?= 10
dudect: $(DUDE_RESULTS)

$(EVAL_DIR)/dudect/node_modules:
	npm install --prefix $(EVAL_DIR)/dudect

$(DUDE_RESULTS): $(DUDECT_PATH) $(DUDE_WASMS) | $(EVAL_DIR)/dudect/node_modules
	mkdir -p $(RESULTS_DIR)/dudect
	timeout $(DUDE_TIMEOUT) sh -c 'stdbuf -oL $(DUDECT_PATH) "$(CT_NODE_PATH) $(patsubst %.txt, $(EVAL_DIR)/dudect/bench_%.js, $(notdir $@))" > $@' || true

$(DUDECT_PATH): $(EVAL_DIR)/.repos/dudect/Makefile
	$(MAKE) -C $(EVAL_DIR)/.repos/dudect

# Memory Benchmarks
MEM_DIR:=$(EVAL_DIR)/memory_benchmarks
MEM_WASMS:=$(MEM_DIR)/local.wasm $(MEM_DIR)/remote.wasm
MEM_ROUNDS:=10000

$(RESULTS_DIR)/memory.csv: $(CT_NODE_PATH) $(MEM_WASMS) 
	echo "Memory tested $(MEM_ROUNDS)" > $(RESULTS_DIR)/memory.txt
	echo "Units in cycles (median)" >> $(RESULTS_DIR)/memory.txt
	mkdir -p $(TMPDIR)/mem
	$(CT_NODE_PATH) $(MEM_DIR)/bench.js $(MEM_ROUNDS) $(MEM_WASMS) $(TMPDIR)/mem
	$(MEM_DIR)/median.py `find $(TMPDIR)/mem/*` > $@


# ------- Plumbing ---------
$(EVAL_DIR)/.repos/ct-wasm-node/Makefile:
	git clone $(CT_NODE_REPO) $(EVAL_DIR)/.repos/ct-wasm-node

$(EVAL_DIR)/.repos/ct-wasm-node/out/Release/node: $(EVAL_DIR)/.repos/ct-wasm-node/Makefile
	$(EVAL_DIR)/.repos/ct-wasm-node/configure
	$(MAKE) -C $(EVAL_DIR)/.repos/ct-wasm-node

$(EVAL_DIR)/.repos/node/Makefile: $(EVAL_DIR)/.repos/ct-wasm-node/Makefile
	mkdir -p $(EVAL_DIR)/.repos/node
	git --git-dir=$(EVAL_DIR)/.repos/ct-wasm-node/.git --work-tree=$(EVAL_DIR)/.repos/node/ checkout $(VN_NODE_HASH) -f -q -- ./

$(EVAL_DIR)/.repos/node/out/Release/node: $(EVAL_DIR)/.repos/node/Makefile
	$(EVAL_DIR)/.repos/node/configure
	$(MAKE) -C $(EVAL_DIR)/.repos/node

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

$(EVAL_DIR)/.repos/dudect/Makefile :
	git clone $(DUDECT_REPO) $(EVAL_DIR)/.repos/dudect
	git --git-dir=$(EVAL_DIR)/.repos/dudect/.git checkout -q $(DUDECT_HASH) 

%.wasm: %.wat $(CT_SPEC_PATH)
	$(CT_SPEC_PATH) -d -i $< -o $@

.SECONDARY: %.wasm
