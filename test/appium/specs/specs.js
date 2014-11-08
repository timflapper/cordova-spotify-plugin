"use strict";

var wd = require('wd')
  , Asserter = wd.Asserter;

var setup = require('./support/setup')
  , driver = setup.driver
  , endOfTestSuite = setup.endOfTestSuite
  , updateAllPassed = setup.updateAllPassed;

describe("SpotifyPlugin", function () {
  this.timeout(600000);

  before(function () {
    var waitForWebViewContext = new Asserter(
      function(driver, cb) {
        return driver
          .contexts()
            .then(function(contexts) {
              var ret = false;
              if (contexts.length > 1) {
                ret = contexts[1];
              }

              cb(null, (ret !== false), ret);
            })
      }
    );

    return driver
      .setAsyncScriptTimeout(300000)
      .waitFor(waitForWebViewContext, 300000)
        .then(function(context) {
          if (! context)
            throw new Error('Context not found.');

          return driver.context(context);
        })
        .fail(function(error) {
          updateAllPassed(false);

          return endOfTestSuite();
        })
      .waitForConditionInBrowser("document.getElementById('page').style.display === 'block';", 30000)
  });

  after(function () {
    return endOfTestSuite();
  });

  afterEach(function () {
    return updateAllPassed(this.currentTest.state === 'passed');
  });

  require('./audio-player')(driver);
});
