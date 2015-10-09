express       = require 'express'

module.exports = (params = {}) ->
  console.log 'on est dans le module'
  app = express()
  app.get "/healthcheck", (req, res, next) ->
    console.log 'Youpi!'
    res.send("Hello World!")
  console.log 'test 2'
  return app
