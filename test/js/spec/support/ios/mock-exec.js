(function() {
  var exec = require('cordova/exec');

  window.mockExec = function(status, result, onRequest) {
    var xhr = sinon.useFakeXMLHttpRequest();

    exec.setJsToNativeBridgeMode(exec.jsToNativeModes.XHR_NO_PAYLOAD);

    xhr.onCreate = function(req) {
      var payload = JSON.parse(exec.nativeFetchMessages())[0]
        , callbackId = payload.shift();

      onRequest(payload);
      exec.nativeCallback(callbackId, status, result, false);

      xhr.restore();
    };
  };
})();
