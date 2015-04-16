
MC_SYSTEMS=simple stdatomic stdvector object-pool lamport-queue

# MC paths: 
MC_BASE_PATH=$(shell pwd)
MC_INCLUDE_PATH=$(MC_BASE_PATH)/include
MC_LIBRARY_PATH=$(MC_BASE_PATH)/lib
MC_BUILD_PATH=$(MC_BASE_PATH)/build
DIV_SUPPLEMENT_LIBRARY_PATH=$(MC_LIBRARY_PATH)/sup

# MC flags: 
#  -D_MC__SIMULATE_STDATOMIC 
#  -D_MC__LOG
MC_FLAGS=-D_MC $(d)

# Command flags: 
INCLUDE_FLAGS=-I$(MC_INCLUDE_PATH)

CCFLAGS=$(MC_FLAGS) $(INCLUDE_FLAGS)
CPPFLAGS=-std=c++11 $(MC_FLAGS) $(INCLUDE_FLAGS)
LINKER_FLAGS=-pthread
DIVCCLANG=clang-compat

DIVCC_CFLAGS=--cflags="$(CCFLAGS) -D_MC__DEBUG_VERIFY"
DIVCPP_CFLAGS=--cflags="$(CPPFLAGS) -D_MC__DEBUG_VERIFY"

DIV_LINKER_FLAGS=--precompiled=$(DIV_SUPPLEMENT_LIBRARY_PATH)
# CC Commands: 
CC=gcc
CPP=g++ -Wall -pedantic

workers=8

# DiVine comands: 
DIVCC=divine compile --llvm --cmd-clang=$(DIVCCLANG)
DIVINFO=divine info 

DIVVERIFY=divine verify --workers=$(workers) --demangle=cpp --compression=tree --reduce=tau+

STDLIB_SUP_FILES=$(DIV_SUPPLEMENT_LIBRARY_PATH)/libdivinert.bc
#								 $(DIV_SUPPLEMENT_LIBRARY_PATH)/libcxxabi.a \
#								 $(DIV_SUPPLEMENT_LIBRARY_PATH)/libdivine.a \
#								 $(DIV_SUPPLEMENT_LIBRARY_PATH)/libpdc.a


.PHONY: all
all : help

.PHONY: help
help: 
	@echo "Verification:  make [ clean ] <target>.v [ p=assert ] [ workers=8 ] [d=-D...]"
	@echo "Dry run:       make [ clean ] <target>.test"
	@echo "Compile .bc:   make [ clean ] <target>.bc"

$(MC_BUILD_PATH):
	mkdir -p $(MC_BUILD_PATH)

.PHONY: tmpclean
tmpclean: 
	find -name '*~' -exec rm -f {} \;
.PHONY: clean
clean: 
	rm -Rf $(MC_BUILD_PATH)/*.bc
	rm -Rf $(MC_BUILD_PATH)/*.out
	rm -Rf $(MC_BUILD_PATH)/*.test
.PHONY: distclean 
distclean: tmpclean
	rm -Rf $(MC_BUILD_PATH)
	rm -Rf $(DIV_SUPPLEMENT_LIBRARY_PATH)

# Immediate targets: ==============================================

$(MC_BUILD_PATH)/%.test %.test: $(MC_BUILD_PATH)/%.out 
	$(EXIT_ON_ERROR)
	$(info [ TEST ])
	$< > $(MC_BUILD_PATH)/$@

$(MC_BUILD_PATH)/%.info %.info: $(MC_BUILD_PATH)/%.bc 
	$(EXIT_ON_ERROR)
	$(info [ DIVINE INFO ])
	$(DIVINFO) $< | tee $(MC_BUILD_PATH)/$@ 

p=assert
$(MC_BUILD_PATH)/%.v.$(p) %.v: $(MC_BUILD_PATH)/%.bc %.info
	$(EXIT_ON_ERROR)
	$(info [ DIVINE VERIFY | $(p) ])
	$(DIVVERIFY) -p $(p) $< -d --report=text:$(MC_BUILD_PATH)/$@.$(p).report 2>&1 | tee $(MC_BUILD_PATH)/$@.$(p)

# =================================================================

$(MC_BUILD_PATH)/%.bc %.bc: %.cpp $(STDLIB_SUP_FILES) $(MC_BUILD_PATH)
	$(EXIT_ON_ERROR)
	$(info [ DIVINE CXX ])
	$(DIVCC) $(DIVCPP_CFLAGS) $(DIV_LINKER_FLAGS) $< -o $@

$(MC_BUILD_PATH)/%.bc %.bc: %.c %.test $(STDLIB_SUP_FILES) $(MC_BUILD_PATH)
	$(EXIT_ON_ERROR)
	$(info [ DIVINE CC ])
	$(DIVCC) $(DIVCC_CFLAGS) $(DIV_LINKER_FLAGS) $< -o $@

.PRECIOUS: $(MC_BUILD_PATH)/%.out

$(MC_BUILD_PATH)/%.out: %.cpp $(STDLIB_SUP_FILES) $(MC_BUILD_PATH)
	$(EXIT_ON_ERROR)
	$(info [ CXX ])
	$(CPP) $(CPPFLAGS) $(LINKER_FLAGS) $< -o $@ 

$(MC_BUILD_PATH)/%.out: %.c $(STDLIB_SUP_FILES) $(MC_BUILD_PATH)
	$(EXIT_ON_ERROR)
	$(info [ CC ])
	$(CC) $(CCFLAGS) $(LINKER_FLAGS) $< -o $@ 

$(STDLIB_SUP_FILES): 
	$(EXIT_ON_ERROR)
	$(info [ STDLIB ] Building stdlibc++ supplement to $(DIV_SUPPLEMENT_LIBRARY_PATH))
	mkdir -p $(DIV_SUPPLEMENT_LIBRARY_PATH) && (cd $(MC_LIBRARY_PATH)/sup; $(DIVCC) --libraries-only)

