var expect = require('expect.js')
var healthcheck = require('../source');

describe('getClient', function() {

  it('should be exported', function() {
    expect(healthcheck).to.be.ok();
    expect(healthcheck.getClient).to.be.ok();
  });

  it('should return the variable', function(done) {
    healthcheck
      .getClient('coucou')
      .then(function(result) {
        expect(result).to.equal('coucou');
        done();
      })
  });

  it('should return the result of the function', function(done) {
    var client = function() {return 'coucou';}
    healthcheck
      .getClient(client)
      .then(function(result) {
        expect(result).to.equal('coucou');
        done();
      })
  });
});
