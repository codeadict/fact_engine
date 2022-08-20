TESTDIRS := $(wildcard ./test/fixtures/*)

all: build

build:
	MIX_ENV=prod mix do deps.get, escript.build

functional_tests: $(TESTDIRS)

$(TESTDIRS):
	 @echo "Testing with input $@/in.txt"
	 @./fact_engine --input $@/in.txt | diff -u --strip-trailing-cr $@/out.txt - && echo "PASS"

.PHONY: all functional_tests $(TESTDIRS)

