development: install
	./bin/install

install:
	npm install

test: test-js test-ios
	
test-js:
	@echo "==JavaScript Unit tests=="
	NODE_PATH=test/js/modules mocha test/js --reporter spec

test-ios:
	@echo "==XCode Unit tests=="
	xctool -project SpotifyPlugin.xcodeproj -scheme SpotifyPlugin -sdk iphonesimulator build test
	
.PHONY: test