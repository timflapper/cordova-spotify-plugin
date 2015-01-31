test:
	@export PLUGIN_ENV='test'; bin/test-all

test-ios:
	@bin/test-ios

test-js:
	@export PLUGIN_ENV='test'; bin/test-js

test-appium:
	@bin/test-appium

prepare: npm development

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
