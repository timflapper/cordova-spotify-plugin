test: test-ios test-js

test-js:
	# @echo "\n\n\x1b[32m\x1b[1m==JavaScript Unit tests==\x1b[0m\n"
	# @npm test

test-ios:
	@echo "\n\n\x1b[32m\x1b[1m==XCode Unit tests==\x1b[0m\n"
	@xctool -project SpotifyPlugin.xcodeproj -scheme SpotifyPlugin -sdk iphonesimulator8.0 test

development: install
	./bin/install

install:
	npm install

.PHONY: test
