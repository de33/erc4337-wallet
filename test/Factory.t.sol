pragma solidity ^0.8.19;

import "forge-std/Test.sol";
import "../src/Wallet.sol";
import "../src/Factory.sol";
import {IEntryPoint} from "../src/interfaces/IEntryPoint.sol";

contract FactoryTest is Test {
    Factory public factory;
    address owner;
    address payable beneficiary;
    IEntryPoint entryPoint;

    function setUp() public {
        beneficiary = payable(address(makeAddr("beneficiary")));
        entryPoint = IEntryPoint(0x5FF137D4b0FDCD49DcA30c7CF57E578a026d2789);
        factory = new Factory();
        owner = makeAddr("owner");
    }

    function testAddress() public {
        address predicted = factory.getAccountAddress(address(0), 1);
        address payable deployed = payable(
            factory.createAccount(address(0), 1)
        );
        assertEq(predicted, deployed);
    }

    function testAddStake() public {
        vm.deal(owner, 2 ether);
        vm.prank(owner);
        factory.addStake{value: 1 ether}(1);

        IEntryPoint.DepositInfo memory depositInfo = entryPoint.getDepositInfo(
            address(factory)
        );

        assertEq(depositInfo.staked, true);
        assertEq(depositInfo.unstakeDelaySec, 1);
        assertEq(depositInfo.stake, 1 ether);
    }
}
