.PHONY: all test lint

all: test lint

test:
	for test_file in shunit2/test*sh ; do \
		bash "$$test_file" ; \
	done

lint:
	shellcheck client.sh
