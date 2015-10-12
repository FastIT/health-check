express       = require 'express'
Promise       = require 'bluebird'

module.exports = (params = {}) ->
  config =
    mongoDbs:         if params.mongoDbs?    then params.mongoDbs    else null
    postgresDbs:      if params.postgresDbs? then params.postgresDbs else null

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

  app.get "/healthcheck", (req, res, next) ->
    answer = {}
    answer['uptime'] = secondes
    promises = []

    #Check postgresDbs connection
    if config.postgresDbs
      postgresDbs = config.postgresDbs()
      for postgresDb in postgresDbs
        promises.push timeQueryAsync(postgresDb)

    promises.push 'mongo'

    #Check mongoDb connection
    if config.mongoDbs
      mongoDbs = config.mongoDbs()
      for mongoDb in mongoDbs
        promises.push collectionNamesAsync(mongoDb)

    if promises.length > 1
      Promise.settle(promises).then (results) ->
        mongo = {}
        postgres = {}
        databases = postgres
        i = 0
        j = 1

        for result in results
          if promises[i] == 'mongo'
            databases = mongo
            j = 1
          else
            if result.isFulfilled()
              databases['database_' + j] = true
            else
              databases['database_' + j] = false
          i++
          j++

        answer['postgres'] = postgres
        answer['mongo'] = mongo
        res.send(answer)
    else
      res.send(answer)
  return app
