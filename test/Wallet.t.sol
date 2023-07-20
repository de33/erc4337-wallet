pragma solidity ^0.8.19;

import "forge-std/Test.sol";
import "../src/Wallet.sol";
import "../src/Factory.sol";
import {IEntryPoint} from "../src/interfaces/IEntryPoint.sol";

contract WalletTest is Test {
    Factory public factory;
    address owner;
    uint256 ownerKey;
    address payable beneficiary;
    IEntryPoint entryPoint;

    function setUp() public {
        beneficiary = payable(address(makeAddr("beneficiary")));
        entryPoint = IEntryPoint(0x5FF137D4b0FDCD49DcA30c7CF57E578a026d2789);
        factory = new Factory();
        (owner, ownerKey) = makeAddrAndKey("owner");
        factory.addStake{value: 1}(1);
    }

    function signUserOpHash(
        Vm _vm,
        uint256 _key,
        IEntryPoint.UserOperation memory _op
    ) internal view returns (bytes memory signature) {
        bytes32 hash = entryPoint.getUserOpHash(_op);
        (uint8 v, bytes32 r, bytes32 s) = _vm.sign(
            _key,
            ECDSA.toEthSignedMessageHash(hash)
        );
        signature = abi.encodePacked(r, s, v);
    }

    function fillUserOp(
        address _sender,
        bytes memory _data
    ) internal view returns (IEntryPoint.UserOperation memory op) {
        op.sender = _sender;
        op.nonce = entryPoint.getNonce(_sender, 0);
        op.callData = _data;
        op.callGasLimit = 10000000;
        op.verificationGasLimit = 10000000;
        op.preVerificationGas = 50000;
        op.maxFeePerGas = 50000;
        op.maxPriorityFeePerGas = 1;
    }

    function testUserOp() public {
        address payable deployed = payable(factory.createAccount(owner, 1));
        vm.deal(deployed, 2 ether);
        uint256 nonce = Wallet(deployed).getNonce();
        assertEq(nonce, 0);
        IEntryPoint.UserOperation memory op = fillUserOp(
            address(deployed),
            abi.encodeWithSelector(
                Wallet.execute.selector,
                owner,
                1 ether,
                hex""
            )
        );
        op.signature = abi.encodePacked(signUserOpHash(vm, ownerKey, op));
        IEntryPoint.UserOperation[]
            memory ops = new IEntryPoint.UserOperation[](1);
        ops[0] = op;
        entryPoint.handleOps(ops, beneficiary);
        nonce = Wallet(deployed).getNonce();
        assertEq(nonce, 1);
    }

    function testExecute() public {
        address payable deployed = payable(factory.createAccount(owner, 1));
        vm.deal(owner, 2 ether);
        vm.deal(deployed, 2 ether);
        vm.prank(owner);
        Wallet(deployed).execute(owner, 1 ether, hex"");
    }
}
