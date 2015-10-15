expect     = require('chai').expect
request    = require 'supertest'
loopback   = require 'loopback'
boot       = require 'loopback-boot'

module        = require('../../main/src/module')
mongo         = require('../mongo')
elasticsearch = require('../elasticsearch')
postgres      = require('../postgres')

describe 'loopback module', ->
  agent = null

  before (done) ->
    app = loopback()
    app.set 'port', 3388
    app.set 'url', "0.0.0.0"
    app.set 'legacyExplorer', false
    app.set 'baseUri', '/'
    ds = loopback.createDataSource
      database: "testDb",
      connector: "loopback-connector-mongodb",
      hostname: "localhost",
      port: 27017,
      username: "pacman",
      password: "pacmanpass"
    model = ds.createModel 'MyModel', {},
      base: 'Model'
      plural: 'my-model'
    app.model model

    app.use module
      mongoDbs: ->
        [ds.connector.db]
    setTimeout done, 200
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
