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
  "uptime": 42 // in seconds
}
```
