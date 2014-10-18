(function() {
  if (cordova.platformId === 'ios') {
    loadScript('spec/support/ios/mock-exec.js');
  } else if (cordova.platformId === 'android') {
    console.error('Platform ' + cordova.platformId + ' is not yet supported.');
  } else {
    console.error('Platform ' + cordova.platformId + ' is not a valid platform.');
  }

  function onScriptError(err) {
    console.error('The script ' + err.target.src + ' is not accessible.');
  }

  function loadScript(url, callback) {
    var script = document.createElement("script");
    script.onload = callback;
    script.onerror = onScriptError;
    script.src = url;
    document.head.appendChild(script);
  }
})();
