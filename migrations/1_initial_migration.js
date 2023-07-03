const KRWN = artifacts.require("KRWN");

module.exports = function (deployer) {
  deployer.deploy(KRWN, 'ipfs://bafybeigbqfruihxljwr72ydxqrfoj765fp6x5czbb3mjewr7au53y2rlqy/');
};
