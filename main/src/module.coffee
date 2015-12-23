express = require 'express'
Promise = require 'bluebird'
prettyHrtime = require 'pretty-hrtime'
_ = require 'lodash'

module.exports = (params = {}) ->
  defaultConfig =
    urn: '/api/health-check'
    getMongoConnections: null
  config = _.defaults params, defaultConfig

  app = express()
  start = process.hrtime()

  uptime = ->
    prettyHrtime process.hrtime start

  pingMongoAsync = (mongoConnectionDb) ->
    new Promise (fulfill,reject)->
      mongoConnectionDb.collection('dummy').findOne { _id: 1 }, (err,result) ->
        return reject err if err?
        fulfill result
    .timeout(1000)

  timeQueryAsync = (postgresClient) ->
    new Promise((fulfill,reject)->
      callback = (err,result) ->
        if err
          return reject err
        else
          return fulfill result

      postgresClient.query 'SELECT NOW() AS "theTime"', callback
      ).timeout(1000)

  pingElasticsearchAsync = (elasticsearchClt) ->
    new Promise((fulfill,reject) ->
      callback = (err,result) ->
        if err
          return reject err
        else
          return fulfill result

      elasticsearchClt.ping {
        requestTimeout: 3000
        hello: 'elasticsearch!'
        }, callback
    )

  app.get config.urn, (req, res, next) ->
    body = {}
    body['uptime'] = uptime()
    promises = []

    #Check postgresDbs connections
    if config.postgresDbs
      postgresDbs = config.postgresDbs()
      for postgresDb in postgresDbs
        promises.push timeQueryAsync(postgresDb)

    checkMongo = (driver, dbConfig) ->

      new Promise (fulfill,reject)->
        Db = driver.Db
        MongoClient = driver.MongoClient
        Server = driver.Server

        db = new Db dbConfig.name, new Server(dbConfig.address, dbConfig.port)
        # Establish connection to db
        db.open (err, db) ->
          return reject err if err?
          # Use the admin database for the operation
          adminDb = db.admin()

          # Retrive the server Info
          adminDb.serverStatus (err, info) ->
            db.close()
            return reject err if err?
            return fulfill info

    # Check mongo
    if config.mongo?.driver? and config.mongo?.config?
      mongoPromise = checkMongo config.mongo.driver, config.mongo.config


    # promises.push 'elasticsearch'
    #
    # #Check elasticsearch connections
    # if config.elasticsearchClts
    #   elasticsearchClts = config.elasticsearchClts()
    #   for elasticsearchClt in elasticsearchClts
    #     promises.push pingElasticsearchAsync(elasticsearchClt)
    #
    mongoPromise.then (info) ->
      body['mongo'] =
        status: if info.ok is 1 then 'ok' else 'ko'
        uptime: info.uptime
        connections: info.connections
    .catch (err) ->
      body['mongo'] =
        status: 'ko'
    .finally ->
      res.send body
  return app
