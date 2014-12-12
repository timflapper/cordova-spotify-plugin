var wd = require('wd')
  , path = require('path')

require('colors');

var chai = require('chai')
  , chaiAsPromised = require('chai-as-promised')
  , should = chai.should();

chai.use(chaiAsPromised);
chaiAsPromised.transferPromiseness = wd.transferPromiseness;

var allPassed = true;

var driver = setupDriver();

function setupDriver() {
  var appiumServers = require('./appium-servers');

  var serverConfig = process.env.SAUCE ?
    appiumServers.sauce : appiumServers.local;
  var driver = wd.promiseChainRemote(serverConfig);

  var desired = {
    name: 'SpotifyPlugin Test',
    browserName: '',
    'appium-version': '1.3.1',
    platformName: 'iOS',
    platformVersion: '8.1',
    deviceName: 'iPhone 6',
    app: undefined // will be set later
  };

  if (process.env.SAUCE) {
    desired.app = 'sauce-storage:AcceptanceTest.zip';
  } else {
    desired.app = path.join(process.cwd(), '.tmp/TestApp/platforms/ios/build/emulator/AcceptanceTest.app');
  }

  return driver.init(desired);
}

function endOfTestSuite() {
  return driver
    .quit()
    .finally(function () {
      if (process.env.SAUCE) {
        return driver.sauceJobStatus(allPassed);
      }
    });
}

function updateAllPassed(state) {
  allPassed = allPassed && state;
}

exports.should = should;

exports.driver = driver;

exports.endOfTestSuite = endOfTestSuite;

exports.updateAllPassed = updateAllPassed;


