development: install
	@./bin/install

install:
	@npm install

test: test-js test-ios
	
test-js:
	@echo "==JavaScript Unit tests=="
	@NODE_PATH=test/js/modules mocha test/js --reporter spec

test-ios:
	@echo "==XCode Unit tests=="
	@xctool -scheme SpotifyPlugin -sdk iphonesimulator build-tests > /dev/null
	@xctool -scheme SpotifyPlugin -sdk iphonesimulator run-tests
	
.PHONY: test