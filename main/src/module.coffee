express       = require 'express'
Promise       = require 'bluebird'

module.exports = (params = {}) ->
  config =
    mongoDbs: if params.mongoDbs? then params.mongoDbs else null

  app = express()

  days     = 0
  hours    = 0
  minutes  = 0
  secondes = 0

  chrono = ->
    secondes += 1
    if secondes > 59
      minutes += 1
      secondes = 0
      if minutes > 59
        hours += 1
        minutes = 0
        if hours > 23
          days += 1
          hours = 0

  setInterval chrono,1000

  collectionNamesAsync = (connectionDb) ->
    new Promise((fulfill,reject)->
      connectionDb.collectionNames (err,items) ->
        if err
          return reject err
        return fulfill items
      )

  app.get "/healthcheck", (req, res, next) ->
    answer = {}
    answer['Uptime'] = days + 'd ' + hours + 'h ' + minutes + 'm ' + secondes + 's'

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
          mongo['database ' + i] = result.value()
        else
          # mongo['datasource ' + i] = String result.reason()
          mongo['database ' + i] = 'Error'
      answer['Mongo connections'] = mongo
      res.send(answer)

  return app
