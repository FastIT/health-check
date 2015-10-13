express       = require 'express'
Promise       = require 'bluebird'

module.exports = (params = {}) ->
  config =
    mongoDbs:               if params.mongoDbs?           then params.mongoDbs                  else null
    postgresDbs:            if params.postgresDbs?        then params.postgresDbs               else null
    elasticsearchClts:      if params.elasticsearchClts?  then params.params.elasticsearchClts  else null

  app = express()
  secondes = 0
  setInterval (()-> secondes++),1000

  collectionNamesAsync = (mongoConnectionDb) ->
    new Promise((fulfill,reject)->
      mongoConnectionDb.collectionNames (err,items) ->
        if err
          return reject err
        return fulfill items
      )

  timeQueryAsync = (postgresClient) ->
    new Promise((fulfill,reject)->
      postgresClient.connect (err,items)->
        if err
          return reject err
        else
          postgresClient.query 'SELECT NOW() AS "theTime"', (err, result) ->
            if err
              return reject err
            else
              postgresClient.end()
              return fulfill result
      )

  pingAsync = (elasticsearchClt) ->
    new Promise((fulfill,reject) ->
      elasticsearchClt.ping {
        requestTimeout: 3000
        hello: 'elasticsearch!'
        }, (err) ->
          if err
            return reject err
          else
            return fulfill true
    )

  app.get "/healthcheck", (req, res, next) ->
    answer = {}
    answer['uptime'] = secondes
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
        promises.push collectionNamesAsync(mongoDb)

    promises.push 'elasticsearch'

    #Check elasticsearch connections
    if config.elasticsearchClts
      elasticsearchClts = config.elasticsearchClts
      for elasticsearchClt in elasticsearchClts
        promises.push pingAsync(elasticsearchClt)

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
