mongodb     = require 'mongodb'
config      = require "./config/mongo.config"
MongoClient = mongodb.MongoClient
Server      = mongodb.Server

mongo =
  mongoClient: null
  mongoDb: null

mongo.init = ( next = -> return null ) ->
  server = new Server(config.db.address, config.db.port, {auto_reconnect: true})
  mongo.mongoClient = new MongoClient(server)

  mongo.mongoClient.open (err, client) ->
    mongo.mongoDb = mongo.mongoClient.db config.db.name
    mongo.mongoDb.authenticate config.db.username, config.db.password, (err) ->
      next()

module.exports = mongo
