var expect = require('expect.js')
var request = require('supertest');
var healthcheck = require('../source');

describe('server', function() {

  it('should use default urn', function(done) {
    request(healthcheck())
      .get('/api/health-check')
      .expect(200, done);
  });

  it('should use specified urn', function(done) {
    request(healthcheck({urn: '/coucou'}))
      .get('/coucou')
      .expect(200, done);
  });

  it('should return 200 when calling health-check-vip', function(done) {
    request(healthcheck())
      .get('/api/health-check-vip')
      .expect(200, done);
  });

  it('should return 200 when calling health-check-vip with specified urn', function(done) {
    request(healthcheck({urn: '/coucou'}))
      .get('/coucou-vip')
      .expect(200, done);
  });

});
