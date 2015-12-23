pg          = require 'pg'
config      = require "./config/postgres.config"

conString = "postgres://" + config.db.username + ":" + config.db.password + "@" + config.db.host + ":" + config.db.port + "/" + config.db.name

postgres =
  postgresClient: new pg.Client conString

module.exports = postgres
