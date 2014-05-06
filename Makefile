development: install
	./bin/install

install:
	npm install

test: test-js test-ios
	
test-js:
	@echo "==JavaScript Unit tests=="
	npm test

test-ios:
	@echo "==XCode Unit tests=="
	xctool -project SpotifyPlugin.xcodeproj -scheme SpotifyPlugin -sdk iphonesimulator build test
	
.PHONY: test