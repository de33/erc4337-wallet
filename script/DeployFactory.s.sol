pragma solidity ^0.8.19;

import "../src/Factory.sol";
import "forge-std/Script.sol";
import "forge-std/console.sol";

contract DeployKernel is Script {
    function run(bytes32 salt) public {
        uint256 key = vm.envUint("DEPLOYER_PRIVATE_KEY");
        vm.startBroadcast(key);
        Factory factory = new Factory{salt: salt}();
        console.log("Factory deployed at: %s", address(factory));
        vm.stopBroadcast();
    }
}
