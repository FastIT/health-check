var Promise = require('bluebird');
var _ = require('lodash');
var express = require('express');
var prettyHrtime = require('pretty-hrtime');
var os = require('os');

var check = function(options) {
  return Promise.props(_.reduce(options, function (db, value, key) {
    switch (key) {
      case 'elasticsearch':
        return _.assign(db, {
          elasticsearch: checkItem(checkElasticsearch, value.client)
        });
      case 'mongo':
        return _.assign(db, {
          mongo: checkItem(checkMongo, value.client)
        });
      case 'postgres':
        return _.assign(db, {
          postgres: checkItem(checkPostgres, value.client)
        });
      default:
        return db;
    }
  }, {
    online: true,
    server: checkServer()
  })).then(function(result) {
    return _.reduce(result, function(db, value, key) {
      db['online'] = db['online'] && value.online;
      db[key] = value;
      return db;
    }, {online: true})
  }).then(function(result) {
    result.status = result.online ? 'ok' : 'ko';
    return result;
  });
};

var checkItem = function(fn, client) {
  return Promise.resolve(getClient(client))
    .then(fn)
    .timeout(1000)
    .then(function() {
      return {status: 'ok', online: true};
    })
    .catch(function(err) {
      return {status: 'ko', online: false, error: err}
    });
};

var getClient = function(client) {
  if (_.isFunction(client)) {
    return Promise.resolve(client());
  } else {
    return Promise.resolve(client);
  }
}

var checkServer = function() {
  return Promise.resolve({
    online: true,
    os: {
      arch: os.arch(),
      loadavg: os.loadavg(),
      freemem: os.freemem(),
      platform: os.platform(),
      totalmem: os.totalmem(),
      uptime: os.uptime(),
      release: os.release(),
    },
    process: {
      execArgv: process.execArgv,
      execPath: process.execPath,
      memoryUsage: process.memoryUsage(),
      pid: process.pid,
      platform: process.platform,
      uptime: process.uptime(),
    },
    uptime: prettyHrtime(process.uptime()),
    status: 'ok',
  })
};

var checkMongo = function (client) {
  return new Promise(function(resolve, reject) {
    client.collection('system.indexes').findOne({}, function(err, res) {
      if (err) return reject(err);
      resolve();
    });
  });
};

var checkPostgres = function(client) {
  return new Promise(function(resolve, reject) {
    client.query('SELECT NOW() AS "the_time"', function(err, res) {
      if (err) return reject(err);
      resolve();
    });
  });
};

var checkElasticsearch = function(client) {
  return new Promise(function(resolve, reject) {
    client.ping({
      requestTimeout: 3000,
      hello: 'elasticsearch!'
    }, function(err, res) {
      if (err) return reject(err);
      return resolve();
    });
  });
};

module.exports = exports = function(params) {
  var urn = params && params.urn ? params.urn : '/api/health-check';
  var app = express.Router();
  app.get(urn, function(req, res) {
    check(params)
      .then(function(result) {
        return res.status(result.status === 'ok' ? 200 : 503).send(result);
      })
      .catch(function() {
        return res.status(500).send('something is broken');
      });
  });
  app.get(urn + '-vip', function(req, res) {
    check(params)
      .then(function(result) {
        return res.sendStatus(result.status === 'ok' ? 200 : 503);
      })
      .catch(function() {
        return res.sendStatus(500);
      });
  });
  return app;
};

exports.check = check;
exports.checkElasticsearch = checkElasticsearch;
exports.checkItem = checkItem;
exports.checkMongo = checkMongo;
exports.checkPostgres = checkPostgres;
exports.checkServer = checkServer;
exports.getClient = getClient;
