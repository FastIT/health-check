express = require 'express'
elasticsearch = require 'elasticsearch'

config =
  elasticsearch:
    elasticClient: new elasticsearch.Client
      host: 'localhost:9200'
      log: null
      index: 'storevol'

app = express()
healthcheck = require('../main/src/module') config
app.use healthcheck

app.server = app.listen 3000
