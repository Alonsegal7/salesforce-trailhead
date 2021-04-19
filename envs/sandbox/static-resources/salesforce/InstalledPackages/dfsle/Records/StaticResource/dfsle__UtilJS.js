window._format = (function (s) {
  if (s) {
    var outerArguments = arguments;
    return s.replace(/{(\d+)}/g, function () {
      return outerArguments[parseInt(arguments[1]) + 1];
    });
  }
  return '';
});

window._formatSize = (function (size, precision) {
  if (!size || typeof size !== 'number' || size < 0) {
    return '0 B';
  }

  var constant = 1024;
  var p = precision || 2;
  var exponents = ['B', 'kB', 'MB', 'GB', 'TB', 'PB', 'EB', 'ZB', 'YB'];
  var factor = Math.floor(Math.log(size) / Math.log(constant));

  return parseFloat((size / Math.pow(constant, factor)).toFixed(p)) + ' ' + exponents[factor];
});

window._getErrorMessage = (function (response) {
  var message = '';
  if (response) {
    var errors = response.getError();
    message = errors;
    if (Array.isArray(errors) && errors.length > 0) {
      message = errors[0].message;
    }
  }
  return message;
});

window._isInIFrame = (function () {
  var inIFrame;
  try {
    // Check to see if we can talk to the parent.
    inIFrame = window.self !== window.parent && (!!parent._isInIFrame);
  } catch (e) {
    inIFrame = false;
  }
  return inIFrame;
});

window._isLightningOrSF1 = (function () {
  return typeof sforce !== 'undefined' && sforce && (!!sforce.one);
});

window._isInNewWindow = (function () {
  return (!!window.opener);
});

/**
 * @description Navigates to an sObject in Lightning, Salesforce1, or Classic.
 * @param id {String} - Id of source Salesforce object.
 * @param pathPrefix {String} - Optional prefix for path.
 */
window._navigateToSObject = (function (id, pathPrefix) {
  if (window._isInIFrame()) {
    window.parent._navigateToSObject(id, pathPrefix);
  } else if (window._isLightningOrSF1()) {
    sforce.one.navigateToSObject(id);
  } else {
    window.location.href = (!!pathPrefix) ? pathPrefix + '/' + id : '/' + id;
  }
});
