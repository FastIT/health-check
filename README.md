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
  "postgres": {
    "status": "ok", // or ko
  },
  "mongo": {
    "status": "ok", // or ko
  },
  "elasticsearch": {
    "status": "ok", // or ko
  }
}
```

# Database health check

## Postgres

Example with postgres-node:

```coffeescript
express = require 'express'
pg = require 'pg'

db =
  name: 'dbname'
  host: 'localhost'
  port: '5432'
  username: 'user'
  password: 'pwd'

connectionString = "postgres://#{db.username}:#{db.password}@#{db.host}:#{db.port}/#{db.name}"

config =
  postgres:
    client: new pg.Client connectionString

app = express()
healthcheck = require('../main/src/module') config
app.use healthcheck

app.server = app.listen 3000
```

## Mongo

Example with mongo-db:

```coffeescript
express = require 'express'
mongodb = require 'mongodb'

db =
  name: 'dbname'
  host: 'localhost'
  port: '5432'
  username: 'user'
  password: 'pwd'
connectionString = "mongodb://#{db.username}:#{db.password}@#{db.host}:#{db.port}/#{db.name}"

MongoClient = mongodb.MongoClient
mongoClient = new MongoClient()

app = express()

mongo.mongoClient.connect url, (err, db) ->
  return if err?
  config =
    mongo:
      client: db
  healthcheck = require('../main/src/module') config
  app.use healthcheck

  app.server = app.listen 3000

```

## Elasticsearch

```coffeescript

elasticsearch = require 'elasticsearch'
express = require 'express'

config =
  host: 'localhost'
  port: 9200

app = express()

config =
  elasticsearch =
    client: new elasticsearch.Client
      host: config.host + ':' + config.port
      log: 'debug'

healthcheck = require('../main/src/module') config
app.use healthcheck

app.server = app.listen 3000

```
