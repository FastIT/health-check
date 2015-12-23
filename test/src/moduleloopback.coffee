expect = require('chai').expect
request = require 'supertest'
loopback = require 'loopback'
boot = require 'loopback-boot'

module = require('../../main/src/module')
mongo = require('../mongo')
elasticsearch = require('../elasticsearch')
postgres = require('../postgres')

describe 'loopback module', ->
  agent = null

  before (done) ->
    app = loopback()
    app.set 'port', 3388
    app.set 'url', "0.0.0.0"
    app.set 'legacyExplorer', false
    app.set 'baseUri', '/'
    mongo = loopback.createDataSource
      database: "base_test"
      connector: "loopback-connector-mongodb"
      hostname: "localhost"
      port: 27017
      username: "pacman"
      password: "pacmanpass"
    mongoModel = mongo.createModel 'MyModel', {},
      base: 'Model'
      plural: 'my-model'

    postgres = loopback.createDataSource
      database: "base_test"
      connector: "postgresql"
      hostname: "localhost"
      username: "pacman"
    postgresModel = postgres.createModel 'MyModel', {},
      name:
        type: 'String'
        required: false

    elasticsearch = loopback.createDataSource
      host: 'localhost'
      port: 9200
      name: 'elastic'
      connector: 'es'


    app.model mongoModel
    app.model postgresModel

    setTimeout ->
      app.use module
        mongo:
          client: mongo.connector.db
        postgres:
          client: postgres.connector.client
        elasticsearch:
          client: elasticsearch.connector.db
      agent = request app
      done()
    , 1000

  describe 'GET /api/health-check', ->
    it 'should respond 200 code', (done) ->
      agent.get '/api/health-check'
      .end (err, res) ->
        expect(res.statusCode).to.eql 200
        done()

    it 'should detect a connection to mongodb', (done) ->
      agent.get '/api/health-check'
      .end (err, res) ->
        expect(res.body.mongo).to.eql {status: 'ok'}
        done()

    it 'should detect a connection to postgres', (done) ->
      agent.get '/api/health-check'
      .end (err, res) ->
        expect(res.body.postgres).to.eql {status: 'ok'}
        done()

    it 'should detect a connection to elasticsearch', (done) ->
      agent.get '/api/health-check'
      .end (err, res) ->
        expect(res.body.elasticsearch).to.eql {status: 'ok'}
        done()
