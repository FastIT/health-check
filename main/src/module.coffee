express       = require 'express'
Promise       = require 'bluebird'

module.exports = (params = {}) ->
  config =
    urn:                    if params.urn                 then params.urn                 else '/api/health-check'
    mongoDbs:               if params.mongoDbs?           then params.mongoDbs            else null
    postgresDbs:            if params.postgresDbs?        then params.postgresDbs         else null
    elasticsearchClts:      if params.elasticsearchClts?  then params.elasticsearchClts   else null

  app = express()
  uptime = process.hrtime


  pingMongoAsync = (mongoConnectionDb) ->
    new Promise((fulfill,reject)->
      callback = (err,result) ->
        if err
          return reject err
        else
          return fulfill result

      if mongoConnectionDb.dataSource
        mongoConnectionDb.ping callback
      else
        mongoConnectionDb.collection('dummy').findOne { _id: 1 }, callback
      ).timeout(1000)

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
    answer = {}
    answer['uptime'] = uptime()
    promises = []

    #Check postgresDbs connections
    if config.postgresDbs
      postgresDbs = config.postgresDbs()
      for postgresDb in postgresDbs
        promises.push timeQueryAsync(postgresDb)

    promises.push 'mongo'

    #Check mongoDb connections
    if config.mongoDbs
      mongoDbs = config.mongoDbs()
      for mongoDb in mongoDbs
        promises.push pingMongoAsync(mongoDb)

    promises.push 'elasticsearch'

    #Check elasticsearch connections
    if config.elasticsearchClts
      elasticsearchClts = config.elasticsearchClts()
      for elasticsearchClt in elasticsearchClts
        promises.push pingElasticsearchAsync(elasticsearchClt)

    if promises.length > 2
      Promise.settle(promises).then (results) ->
        mongo = {}
        postgres = {}
        elastic = {}
        databases = postgres
        i = 0
        j = 1

        for result in results
          if promises[i] == 'mongo'
            databases = mongo
            j = 1
          else if promises[i] == 'elasticsearch'
            databases = elastic
            j = 1
          else
            if result.isFulfilled()
              databases['database_' + j] = true
            else
              databases['database_' + j] = false
            j++
          i++

        answer['postgres']        = postgres
        answer['mongo']           = mongo
        answer['elasticsearch']   = elastic
        res.send(answer)
    else
      res.send(answer)
  return app
