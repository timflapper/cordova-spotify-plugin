test: test-ios test-appium

test-ios:
	@echo "\n\n\x1b[32m\x1b[1m==XCode Unit tests==\x1b[0m\n"
	@xctool -project SpotifyPlugin.xcodeproj -scheme SpotifyPlugin -sdk iphonesimulator7.1 test

test-js:
	@echo "\n\n\x1b[32m\x1b[1m==JavaScript Unit tests==\x1b[0m\n"
	@npm test

test-appium:
	@echo "\n\n\x1b[32m\x1b[1m==Appium Acceptance Tests==\x1b[0m\n"
	@bin/test-appium

prepare: npm development appium

clean:
	@bin/clean
	@bin/clean-appium

npm:
	@npm install

appium:
	@bin/create-appium

development:
	@bin/install

.PHONY: test
