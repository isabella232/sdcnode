#
# Copyright (c) 2012, Joyent, Inc. All rights reserved.
#
# SDC Node makefile.
#

include ./tools/mk/Makefile.defs


#
# Files
#
CLEAN_FILES += bits
DISTCLEAN_FILES += build
DOC_FILES += index.restdown

ifeq ($(UPLOAD_LOCATION),)
	UPLOAD_LOCATION=stuff@stuff.joyent.us:builds
endif



#
# Repo-specific targets
#
.PHONY: all
all: build/src nodes bits

build/src:
	git clone git://github.com/joyent/node.git build/src

.PHONY: nodesrc
nodesrc: | build/src
	cd build/src && git checkout master \
		&& git fetch origin && git pull --rebase origin master
	rm -rf build/src.tgz
	cd build/src && tar czf ../src.tgz .

.PHONY: nodes
nodes: nodesrc
	rm -rf bits/sdcnode
	mkdir -p bits/sdcnode
	./tools/build-all-nodes $(STAMP)

.PHONY: bits
bits:
	rm -rf $(TOP)/bits
	mkdir -p $(TOP)/bits/sdcnode
	cp $(TOP)/build/nodes/*/sdcnode-*.tgz $(TOP)/bits/sdcnode

# The "publish" target requires that "BITS_DIR" be defined.
# Used by Mountain Gorilla.
.PHONY: publish
publish: bits $(BITS_DIR)
	@if [[ -z "$(BITS_DIR)" ]]; then \
		echo "error: 'BITS_DIR' must be set for 'publish' target"; \
		exit 1; \
	fi
	mkdir -p $(BITS_DIR)/sdcnode
	cp $(TOP)/bits/sdcnode/sdcnode-*.tgz $(BITS_DIR)/sdcnode

# Upload bits to stuff
.PHONY: upload
upload:
	./tools/upload-bits "$(BRANCH)" "" "$(TIMESTAMP)" $(UPLOAD_LOCATION)/sdcnode

.PHONY: dumpvar
dumpvar:
	@if [[ -z "$(VAR)" ]]; then \
		echo "error: set 'VAR' to dump a var"; \
		exit 1; \
	fi
	@echo "$(VAR) is '$($(VAR))'"


include ./tools/mk/Makefile.deps
include ./tools/mk/Makefile.targ
