express       = require 'express'

module.exports = (params = {}) ->
  app = express()
  app.get "/healthcheck", (req, res, next) ->
    res.send("Hello World!")
  return app
