expect  = require('chai').expect
express = require 'express'
request = require 'supertest'

module        = require('../../main/src/module')
mongo         = require('../mongo')
elasticsearch = require('../elasticsearch')

app = null
server = null

port = 9876
url  = 'http://localhost:' + port

startServer = (callback = ( -> return )) ->
  app = express()

  app.use module
    mongoDbs: ->
      [mongo.mongoDb]
    elasticsearchClts:
      [elasticsearch.elasticClient]

  mongo.init ->
    server = app.listen port, callback

stopServer = (callback = ( -> return )) ->
  server.close callback
  mongo.mongoClient.close()

describe 'module', ->
  agent = null

  beforeEach (done) ->
    startServer done
    agent = request.agent app

  afterEach (done) ->
    stopServer done

  describe 'GET /api/health-check', ->
    it 'should respond 200 code', (done) ->
      agent.get '/api/health-check'
      .end (err, res) ->
        expect(res.statusCode).to.eql 200
        done()

    it 'should detecte connection to mongodb', (done) ->
      agent.get '/api/health-check'
      .end (err, res) ->
        expect(res.body.mongo).to.eql {database_1: true}
        done()

    it 'should not dectecte any connection to mongodb', (done) ->
      mongo.mongoClient.close()
      agent.get '/api/health-check'
      .end (err, res) ->
        expect(res.body.mongo).to.eql {database_1: false}
        done()

    it 'should detecte connection to elasticsearch', (done) ->
      agent.get '/api/health-check'
      .end (err, res) ->
        expect(res.body.elasticsearch).to.eql {database_1: true}
        done()
