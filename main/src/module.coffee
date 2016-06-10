express      = require 'express'
Promise      = require 'bluebird'
prettyHrtime = require 'pretty-hrtime'
_            = require 'lodash'
os           = require 'os'

module.exports = (params = {}) ->
  defaultParams =
    urn: '/api/health-check'
  config = _.defaults params, defaultParams

  app = express()
  start = process.hrtime()

  uptime = ->
    prettyHrtime process.hrtime start

  processInfos = ->
    [
      pid         : process.pid,
      arch        : process.arch,
      platform    : process.platform,
      memoryUsage : process.memoryUsage(),
      uptime      : process.uptime(),
      execPath    : process.execPath,
      execArgv    : process.execArgv
    ]

  osInfos = ->
    [
      platform : os.platform(),
      arch     : os.arch(),
      release  : os.release(),
      uptime   : os.uptime(),
      loadavg  : os.loadavg(),
      totalmem : os.totalmem(),
      freemem  : os.freemem()
    ]

  globalStatus = (statuses) ->
    for status in statuses
      if status is 'ko'
        return 'ko'
    'ok'

  pingMongoAsync = (mongoConnectionDb) ->
    new Promise((fulfill,reject)->
      callback = (err,result) ->
        if err
          return reject err
        else
          return fulfill result

      mongoConnectionDb.collection('system.indexes').findOne {}, callback
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
    response = {}
    new Promise (fulfill,reject) ->
      elasticsearchClt.ping {
        requestTimeout: 3000
        hello: 'elasticsearch!'
        }, (err, isOK) ->
          if isOK
            response.status = 'ok'
            elasticsearchClt.cluster.health {}, (err, clusterHealth) ->
              response.cluster = clusterHealth
              fulfill response
          else
            response.status = 'ko'
            fulfill response

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

    # Custom checks
    customPromise = null
    if _.isPlainObject config.custom
      checkPromises = []
      for key, check of config.custom
        checkPromises.push new Promise (resolve, reject) ->
          check (err, result) ->
            if err?
              if _.isFunction config.logger?.error
                config.logger.error err
              else
                console.error err
            resolve
              key: key
              result: result
      customPromise = Promise.all checkPromises

    Promise.all([
      mongoPromise
      postgresPromise
      elasticsearchPromise
      customPromise
    ]).then ([mongo, postgres, elasticsearch, custom]) ->
      statuses = []
      if mongo?
        body['mongo'] = mongo
        statuses.push mongo.status
      if postgres?
        body['postgres'] = postgres
        statuses.push postgres.status
      if elasticsearch?
        body['elasticsearch'] = elasticsearch
        statuses.push elasticsearch.status
      if _.isArray custom
        for result in custom
          body[result.key] = result.result
      body.status       = globalStatus statuses
      body.processInfos = processInfos()
      body.osInfos      = osInfos()
      res.send body
  return app
