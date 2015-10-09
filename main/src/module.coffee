express       = require 'express'

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

  app.get "/healthcheck", (req, res, next) ->
    answer = {}
    answer['Uptime'] = days + 'd ' + hours + 'h ' + minutes + 'm ' + secondes + 's'

    #Check mongoDb connection
    if config.mongoDbs
      mongoDbs = config.mongoDbs()
      i = 0
      mongo = {}
      for mongoDb in mongoDbs
        i++
        mongoDb.collectionNames((err,items)->
          mongoitems)
          
    res.send(answer)
  return app
