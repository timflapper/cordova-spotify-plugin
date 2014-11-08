"use strict";

var wd = require('wd')
  , fs = require('fs')
  , path = require('path')
  , chai = require("chai")
  , chaiAsPromised = require("chai-as-promised");

var Asserter = wd.Asserter;

require('colors');

chai.use(chaiAsPromised);
should = chai.should();
chaiAsPromised.transferPromiseness = wd.transferPromiseness;

var serverConfig;

if (process.env.SAUCE) {
  serverConfig = {
    host: 'ondemand.saucelabs.com',
    port: 80,
    username: process.env.SAUCE_USERNAME,
    password: process.env.SAUCE_ACCESS_KEY
  };
} else {
  serverConfig = {
    host: process.env.VM ? '10.211.55.17' : 'localhost',
    port: 4723
  };
}

describe("SpotifyPlugin", function () {
  this.timeout(600000);

  var driver;
  var allPassed = true;

  before(function () {
    driver = wd.promiseChainRemote(serverConfig);

    if (process.env.SAUCE || process.env.DEV) {
      driver.on('status', function (info) {
        console.log(info.cyan);
      });
      driver.on('command', function (meth, path, data) {
        console.log(' > ' + meth.yellow, path.grey, data || '');
      });
      driver.on('http', function (meth, path, data) {
        console.log(' > ' + meth.magenta, path, (data || '').grey);
      });
    }

    var desired = {
      browserName: '',
      'appium-version': '1.3',
      platformName: 'iOS',
      platformVersion: '8.1',
      deviceName: 'iPhone 6',
      app: undefined // will be set later
    };

    if (process.env.SAUCE) {
      desired.app = 'sauce-storage:AcceptanceTest.zip';
    } else {
      desired.app = path.join(process.cwd(), 'tmp/TestApp/platforms/ios/build/emulator/AcceptanceTest.app');
    }

    desired.name = 'SpotifyPlugin Test';

    var waitForWebViewContext = new Asserter(
      function(driver, cb) {
        return driver
          .contexts()
            .then(function(contexts) {
              var ret = (contexts.length > 1) && contexts[1];
              cb(null, (ret !== false), ret);
            });
      }
    );

    return driver.init(desired)
      .setAsyncScriptTimeout(300000)
      .waitFor(waitForWebViewContext, 30000)
        .then(function(context) {
          return driver.context(context);
        })
      .waitForConditionInBrowser("document.getElementById('page').style.display === 'block';", 30000)
  });

  after(function () {
    return driver
      .sleep(5000)
      .quit()
      .finally(function () {
        if (process.env.SAUCE) {
          return driver.sauceJobStatus(allPassed);
        }
      });
  });

  afterEach(function () {
    allPassed = allPassed && this.currentTest.state === 'passed';
  });

  before(function() {
    return driver
      .elementById('loginPlayerLink')
        .click()
      .waitForConditionInBrowser("document.getElementById('loginPlayerStatus').style.display !== 'none';", 30000)
  });

  it('should have a logged in player', function() {
    return driver
      .elementById('loginPlayerStatus')
        .text()
          .should.eventually.equal('success');
  });

  context('playing a song', function() {
    before(function() {
      return driver
        .elementById('playSongLink')
          .click()
        .waitForConditionInBrowser("document.getElementById('playSongStatus').style.display !== 'none';", 30000);
    });

    it('should be able to play a song', function() {
      return driver
        .elementById('playSongStatus')
          .text()
            .should.eventually.equal('success');
    });

    context('volume', function() {
      before(function() {
        return driver
          .elementById('muteLink')
            .click()
          .waitForConditionInBrowser("document.getElementById('muteStatus').style.display !== 'none';", 30000)
      });

      it('should be able to change the volume', function() {
        return driver
          .elementById('muteStatus')
            .text()
              .should.eventually.equal('success');
      });
    });

    context('playback position', function() {
      before(function() {
        return driver
          .sleep(5000)
          .elementById('playbackPositionLink')
            .click()
          .waitForConditionInBrowser("document.getElementById('playbackPosition').style.display !== 'none';", 30000)
      });

      it('should be able to get the playback position', function() {
        return driver
          .elementById('playbackPosition')
            .text()
              .should.eventually.match(/^\d+\.\d+$/);
      });
    })
  });
});
