express = require 'express'
pg = require 'pg'

db =
  name: 'toto'
  host: 'localhost'
  port: '5432'
  username: 'joe'
  password: 'yolo'

connectionString = "postgres://#{db.username}:#{db.password}@#{db.host}:#{db.port}/#{db.name}"

config =
  postgres:
    getPostgresClient: ->
      new pg.Client connectionString

app = express()
healthcheck = require('../main/src/module') config
app.use healthcheck

app.server = app.listen 3000
