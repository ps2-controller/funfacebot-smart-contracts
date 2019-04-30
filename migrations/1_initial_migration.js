var Migrations = artifacts.require("./Migrations.sol");
const FunFaceBot = artifacts.require('./Contracts/funfacebot.sol')

module.exports = function(deployer) {
  deployer.deploy(Migrations);
  deployer.deploy(FunFaceBot);
};
