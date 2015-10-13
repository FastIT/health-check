elasticsearch     = require 'elasticsearch'
config            = require "./config/elasticsearch.config"

elasticsearch =
  elasticClient: new (elasticsearch.Client)(
    host: config.db.address + ':' + config.db.port
    log: config.log.level)

module.exports = elasticsearch
