test: test-ios test-js test-appium

test-ios:
	@echo "\n\n\x1b[32m\x1b[1m==XCode Unit tests==\x1b[0m\n"
	@xcodebuild test -project SpotifyPlugin.xcodeproj -scheme SpotifyPlugin -destination 'platform=iOS Simulator,name=iPhone 5s,OS=7.1' | xcpretty -c && exit ${PIPESTATUS[0]}

test-js:
	@echo "\n\n\x1b[32m\x1b[1m==JavaScript Unit tests==\x1b[0m\n"
	@bin/test-js

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
