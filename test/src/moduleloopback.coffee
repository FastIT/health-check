expect     = require('chai').expect
request    = require 'supertest'
loopback   = require 'loopback'
boot       = require 'loopback-boot'

module        = require('../../main/src/module')
mongo         = require('../mongo')
elasticsearch = require('../elasticsearch')
postgres      = require('../postgres')

app = module.exports = loopback()

app.use module
  mongoDbs: ->
    [app.datasources.mongodb.connector]

app.start = ->
# start the web server
  app.listen ->
    app.emit 'started'
    console.log 'Web server listening at: %s', app.get('url')
    return

boot app, __dirname, (err) ->
  if err
    throw err
  # start the server if `$ node server.js`
  app.start()

describe 'loopback module', ->
  agent = null

  before ->
    agent = request app

  describe 'GET /api/health-check', ->
    it 'should respond 200 code', (done) ->
      agent.get '/api/health-check'
      .end (err, res) ->
        expect(res.statusCode).to.eql 200
        done()

    it 'should detect a connection to mongodb', (done) ->
      agent.get '/api/health-check'
      .end (err, res) ->
        expect(res.body.mongo).to.eql {database_1: true}
        done()
