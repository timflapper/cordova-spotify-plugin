development: install
	./bin/install

install:
	npm install

test: test-ios test-js
	
test-js:
	@echo "==JavaScript Unit tests=="
	npm test

test-ios:
	@echo "==XCode Unit tests=="
	xctool -project SpotifyPlugin.xcodeproj -scheme SpotifyPlugin -sdk iphonesimulator build test
	
.PHONY: test