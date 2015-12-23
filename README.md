# health-check
[![Build Status](https://travis-ci.org/FastIT/health-check.svg?branch=master)](https://travis-ci.org/FastIT/health-check)
[![codecov.io](https://codecov.io/github/FastIT/health-check/coverage.svg?branch=master)](https://codecov.io/github/FastIT/health-check?branch=master)
[![Dependency Status](https://david-dm.org/FastIT/health-check.svg)](https://david-dm.org/FastIT/health-check)

An health check module for express and loopback

# Usage

In your app, add the following code:

```coffeescript
config = {}
healthcheck = require('healthcheck-fastit') config
app.use healthcheck
```

```
curl http://localhost/api/health-check
```

# API response

```javascript
{
  "uptime": 42 // pretty print
  "mongo": {
    "status": "ok", // or ko
    "uptime": 1234, // in seconds
    "connections": {}
  }
}
```
# Database health check

## Get Mongo database status

You should specify the driver and the database config to the healthchecker config:

Example with mongoose:

```coffeescript
mongoose.connection.once 'open', ->
  healthcheck = require('health-check')(
    mongo:
      driver: mongoose.mongo
      config:
        address: 'localhost'
        port: 27017
        name: 'database-name'
  )
  app.use healthcheck
```
