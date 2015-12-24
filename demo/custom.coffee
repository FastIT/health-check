express = require 'express'

config =
  custom:
    hello: (done) ->
      done null, 'hello is OK!'
    dataConsistency: (done) ->
      done null, {
        status: 'ok'
        somethingElse: 123
      }
    error: (done) ->
      done 'Unexpected error'

app = express()
healthcheck = require('../main/src/module') config
app.use healthcheck

app.server = app.listen 3000
