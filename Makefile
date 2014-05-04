test:
	@echo "==JavaScript Unit tests=="
	@NODE_PATH=test/modules mocha
	
test-w:
	@NODE_PATH=test/modules mocha -w test/*.test.js
	
	
.PHONY: test