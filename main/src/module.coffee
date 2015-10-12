express       = require 'express'
Promise       = require 'bluebird'

module.exports = (params = {}) ->
  config =
    mongoDbs: if params.mongoDbs? then params.mongoDbs else null

  app = express()

  secondes = 0

  setInterval (()-> secondes++),1000

  collectionNamesAsync = (connectionDb) ->
    new Promise((fulfill,reject)->
      connectionDb.collectionNames (err,items) ->
        if err
          return reject err
        return fulfill items
      )

  app.get "/healthcheck", (req, res, next) ->
    answer = {}
    answer['uptime'] = secondes

    #Check mongoDb connection
    if config.mongoDbs
      mongoDbs = config.mongoDbs()
      promises = []
      for mongoDb in mongoDbs
        promises.push collectionNamesAsync(mongoDb)

    Promise.settle(promises).then (results) ->
      mongo = {}
      i = 0
      for result in results
        i++
        if result.isFulfilled()
          mongo['database_' + i] = true
        else
          mongo['database_' + i] = false
      answer['mongo'] = mongo
      res.send(answer)

  return app
