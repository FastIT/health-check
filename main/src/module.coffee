express = require 'express'
Promise = require 'bluebird'
prettyHrtime = require 'pretty-hrtime'
_ = require 'lodash'

module.exports = (params = {}) ->
  defaultParams =
    urn: '/api/health-check'
  config = _.defaults params, defaultParams

  app = express()
  start = process.hrtime()

  uptime = ->
    prettyHrtime process.hrtime start

  pingMongoAsync = (mongoConnectionDb) ->
    new Promise((fulfill,reject)->
      callback = (err,result) ->
        if err
          return reject err
        else
          return fulfill result

      mongoConnectionDb.collection('dummy').findOne { _id: 1 }, callback
      ).timeout(1000)

  pingPostgresAsync = (client) ->
    new Promise((fulfill,reject)->
      callback = (err,result) ->
        if err
          return reject err
        else
          return fulfill result

      client.query 'SELECT NOW() AS "theTime"', callback
      ).timeout(1000)

  pingElasticsearchAsync = (elasticsearchClt) ->
    new Promise((fulfill,reject) ->
      callback = (err,result) ->
        if err
          return reject err
        else
          return fulfill result

      elasticsearchClt.ping {
        requestTimeout: 3000
        hello: 'elasticsearch!'
        }, callback
    )

  app.get config.urn, (req, res, next) ->
    body = {}
    body['uptime'] = uptime()

    # Check postgres
    postgresPromise = null
    if config.postgres?.client?
      postgresPromise = pingPostgresAsync config.postgres.client
      .then ->
        status: 'ok'
      .catch (err) ->
        status: 'ko'

    # Check mongo
    mongoPromise = null
    if config.mongo?.client?
      mongoPromise = pingMongoAsync config.mongo.client
      .then ->
        status: 'ok'
      .catch (err) ->
        status: 'ko'

    # Check elasticsearch
    elasticsearchPromise = null
    if config.elasticsearch?.client?
      elasticsearchPromise = pingElasticsearchAsync config.elasticsearch.client
      .then ->
        status: 'ok'
      .catch (err) ->
        status: 'ko'

    Promise.all([
      mongoPromise
      postgresPromise
      elasticsearchPromise
    ]).then ([mongo, postgres, elasticsearch]) ->
      body['mongo'] = mongo
      body['postgres'] = postgres
      body['elasticsearch'] = elasticsearch
      res.send body
  return app
