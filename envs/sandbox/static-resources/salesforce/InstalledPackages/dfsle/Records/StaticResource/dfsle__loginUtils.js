/**
 * Login utility methods.
 * @namespace loginUtils
 */
window.loginUtils = (function () {

  var Type = Object.freeze({
    SETUP: 'SETUP',
    USER: 'USER',
    DEVELOPER: 'DEVELOPER'
  });

  var Status = Object.freeze({
    SUCCESS: 'Success',
    FAILURE: 'Failure',
    SELECT_ACCOUNT: 'SelectAccount'
  });

  return Object.freeze({
    Type: Type,
    Status: Status
  });
}());
