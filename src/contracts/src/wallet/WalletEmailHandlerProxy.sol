// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/proxy/Proxy.sol";
import "@openzeppelin/contracts/proxy/transparent/TransparentUpgradeableProxy.sol";
import "forge-std/console.sol";

contract WalletEmailHandlerProxy is TransparentUpgradeableProxy {
    constructor(address logic, address admin, bytes memory data) TransparentUpgradeableProxy(logic, admin, data) {}

    // function forwardCallToLogic(bytes memory data) public returns (bytes memory) {
    //     (bool success, bytes memory result) = getImplementation().call(data);
    //     require(success, "Forwarded call failed");
    //     return result;
    // }

    function getImplementation() public view returns (address) {
        return _getImplementation();
    }

    function upgradeTo(address newImplementation) public {
        if(msg.sender == _admin() || tx.origin == _admin()) {
            _upgradeTo(newImplementation);
        }
    }
}
