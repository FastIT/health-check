config =
  appRoute: '/app/api'
  authRoute: '/auth/'
  redirectParam: 'sourceURI'
  fields:
    email: 'sggroupid'
    userId: 'sgrtfeid'
    entity: 'sgservicename'
    firstName: 'givenName'
    lastName: 'sn'
  roles: /^role./i
  watchAll: true
  logPath: process.env.TNU_ROOT_DIRECTORY + '/log/node-app/youneedtosetyourlogpathdumbass.log'

module.exports = config
