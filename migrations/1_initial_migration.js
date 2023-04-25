const KRWN = artifacts.require("KRWN");

module.exports = function (deployer) {
  deployer.deploy(KRWN, 'ipfs://bafybeidkqq5k3cpuurn3xfn4qihrbdxesd6suqecucdid66idom4vnx2sy/');
};
