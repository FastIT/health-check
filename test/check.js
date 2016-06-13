var expect = require('expect.js')
var healthcheck = require('../source');

describe('check', function() {

  it('should be exported', function() {
    expect(healthcheck).to.be.ok();
    expect(healthcheck.check).to.be.ok();
  });

  it('should return the server status', function(done) {
    var options = {fake: {}};
    healthcheck.check(options)
      .then(function(result) {
        expect(result).to.be.ok();
        expect(result.online).to.be(true);
        expect(result.status).to.be('ok');
        expect(result.server).to.be.ok();
        expect(result.server.online).to.be(true);
        expect(result.server.status).to.be('ok');
        done();
      });
  });

  describe('postgres', function() {

    it('should return status ok', function(done) {
      var options = {
        postgres: {
          client: {
            query: function(obj, cb) {
              cb();
            }
          }
        }
      };
      healthcheck.check(options)
        .then(function(result) {
          expect(result).to.be.ok();
          expect(result.online).to.be(true);
          expect(result.status).to.be('ok');
          expect(result.server).to.be.ok();
          expect(result.server.online).to.be(true);
          expect(result.server.status).to.be('ok');
          expect(result.postgres).to.be.ok();
          expect(result.postgres.online).to.be(true);
          expect(result.postgres.status).to.be('ok');
          done();
        });
    });

    it('should return status err', function(done) {
      var options = {
        postgres: {
          client: {
            query: function(obj, cb) {
              cb('ERROR !');
            }
          }
        }
      };
      healthcheck.check(options)
        .then(function(result) {
          expect(result).to.be.ok();
          expect(result.online).to.be(false);
          expect(result.status).to.be('ko');
          expect(result.server).to.be.ok();
          expect(result.server.online).to.be(true);
          expect(result.server.status).to.be('ok');
          expect(result.postgres).to.be.ok();
          expect(result.postgres.online).to.be(false);
          expect(result.postgres.status).to.be('ko');
          done();
        });
    });

    it('should return status err if not answer', function(done) {
      var options = {
        postgres: {
          client: {
            query: function(obj, cb) {
            }
          }
        }
      };
      healthcheck.check(options)
        .then(function(result) {
          expect(result).to.be.ok();
          expect(result.online).to.be(false);
          expect(result.status).to.be('ko');
          expect(result.server).to.be.ok();
          expect(result.server.online).to.be(true);
          expect(result.server.status).to.be('ok');
          expect(result.postgres).to.be.ok();
          expect(result.postgres.online).to.be(false);
          expect(result.postgres.status).to.be('ko');
          done();
        });
    });

  });

  describe('mongo', function() {

    it('should return status ok', function(done) {
      var options = {
        mongo: {
          client: {
            collection: function() {
              return {
                findOne: function(obj, cb) {
                  cb();
                }
              }
            }
          }
        }
      };
      healthcheck.check(options)
        .then(function(result) {
          expect(result).to.be.ok();
          expect(result.online).to.be(true);
          expect(result.status).to.be('ok');
          expect(result.server).to.be.ok();
          expect(result.server.online).to.be(true);
          expect(result.server.status).to.be('ok');
          expect(result.mongo).to.be.ok();
          expect(result.mongo.online).to.be(true);
          expect(result.mongo.status).to.be('ok');
          done();
        });
    });

    it('should return status err', function(done) {
      var options = {
        mongo: {
          client: {
            collection: function() {
              return {
                findOne: function(obj, cb) {
                  cb('ERROR !');
                }
              }
            }
          }
        }
      };
      healthcheck.check(options)
        .then(function(result) {
          expect(result).to.be.ok();
          expect(result.online).to.be(false);
          expect(result.status).to.be('ko');
          expect(result.server).to.be.ok();
          expect(result.server.online).to.be(true);
          expect(result.server.status).to.be('ok');
          expect(result.mongo).to.be.ok();
          expect(result.mongo.online).to.be(false);
          expect(result.mongo.status).to.be('ko');
          done();
        });
    });

    it('should return status err if not answer', function(done) {
      var options = {
        mongo: {
          client: {
            collection: function() {
              return {
                findOne: function(obj, cb) {
                }
              }
            }
          }
        }
      };
      healthcheck.check(options)
        .then(function(result) {
          expect(result).to.be.ok();
          expect(result.online).to.be(false);
          expect(result.status).to.be('ko');
          expect(result.server).to.be.ok();
          expect(result.server.online).to.be(true);
          expect(result.server.status).to.be('ok');
          expect(result.mongo).to.be.ok();
          expect(result.mongo.online).to.be(false);
          expect(result.mongo.status).to.be('ko');
          done();
        });
    });

  });

  describe('elasticsearch', function() {

    it('should return status ok', function(done) {
      var options = {
        elasticsearch: {
          client: {
            ping: function(opts, cb) {
              cb();
            }
          }
        }
      };
      healthcheck.check(options)
        .then(function(result) {
          expect(result).to.be.ok();
          expect(result.online).to.be(true);
          expect(result.status).to.be('ok');
          expect(result.server).to.be.ok();
          expect(result.server.online).to.be(true);
          expect(result.server.status).to.be('ok');
          expect(result.elasticsearch).to.be.ok();
          expect(result.elasticsearch.online).to.be(true);
          expect(result.elasticsearch.status).to.be('ok');
          done();
        });
    });

    it('should return status ko', function(done) {
      var options = {
        elasticsearch: {
          client: {
            ping: function(opts, cb) {
              cb('ERROR !');
            }
          }
        }
      };
      healthcheck.check(options)
        .then(function(result) {
          expect(result).to.be.ok();
          expect(result.online).to.be(false);
          expect(result.status).to.be('ko');
          expect(result.server).to.be.ok();
          expect(result.server.online).to.be(true);
          expect(result.server.status).to.be('ok');
          expect(result.elasticsearch).to.be.ok();
          expect(result.elasticsearch.online).to.be(false);
          expect(result.elasticsearch.status).to.be('ko');
          done();
        });
    });

    it('should return status ko', function(done) {
      var options = {
        elasticsearch: {
          client: {
            ping: function(opts, cb) {
            }
          }
        }
      };
      healthcheck.check(options)
        .then(function(result) {
          expect(result).to.be.ok();
          expect(result.online).to.be(false);
          expect(result.status).to.be('ko');
          expect(result.server).to.be.ok();
          expect(result.server.online).to.be(true);
          expect(result.server.status).to.be('ok');
          expect(result.elasticsearch).to.be.ok();
          expect(result.elasticsearch.online).to.be(false);
          expect(result.elasticsearch.status).to.be('ko');
          done();
        });
    });

  });

});
