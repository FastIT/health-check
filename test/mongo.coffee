mongodb     = require 'mongodb'
config      = require "./config/mongo.config"
MongoClient = mongodb.MongoClient

mongo =
  mongoClient: null
  mongoDb: null

mongo.init = ( next = -> return null ) ->
  url = 'mongodb://' + config.db.username + ':' + config.db.password + '@' +config.db.host+':'+ config.db.port + '/' + config.db.name
  mongo.mongoClient = new MongoClient()

  mongo.mongoClient.connect url, (err, db) ->
    if err
      console.log err
    else
      mongo.mongoDb = db
    next()

module.exports = mongo
