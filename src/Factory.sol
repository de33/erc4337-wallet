pragma solidity ^0.8.19;

import {Wallet} from "./Wallet.sol";
import {ERC1967Factory} from "solady/src/utils/ERC1967Factory.sol";
import "forge-std/Test.sol";

contract Factory {
    Wallet public immutable walletImplementation;

    constructor() {
        walletImplementation = new Wallet();
    }

    error CallFailed();

    function createAccount(
        address owner,
        uint256 salt
    ) external returns (address walletAddress) {
        bytes32 uniqueSalt = generateUniqueSalt(owner, salt);
        address walletImpl = address(walletImplementation);

        bytes memory factoryCallData = abi.encodeWithSelector(
            0xa97b90d5, // deployDeterministicAndCall(address,address,bytes32,bytes)
            walletImpl,
            address(this),
            uniqueSalt,
            abi.encodeWithSelector(0xc4d66de8, owner)
        );
        walletAddress = executeERC1967FactoryCall(factoryCallData);
    }

    function executeERC1967FactoryCall(
        bytes memory factoryCallData
    ) internal returns (address walletAddress) {
        assembly {
            let memoryPointer := add(factoryCallData, 0x20)
            let success := call(
                gas(),
                0x6396FF2a80c067f99B3d2Ab4Df24,
                0,
                memoryPointer,
                mload(factoryCallData),
                memoryPointer,
                32
            )
            if iszero(success) {
                mstore(0x00, 0x3204506f) // `CallFailed()`.
                revert(0x00, 0x20)
            }
            returndatacopy(memoryPointer, 0, returndatasize())
            walletAddress := mload(memoryPointer)
        }
    }

    function getAccountAddress(
        address owner,
        uint256 salt
    ) public view returns (address walletAddress) {
        bytes32 uniqueSalt = generateUniqueSalt(owner, salt);
        assembly {
            let memoryPointer := mload(0x40)
            mstore(add(memoryPointer, 0x20), shl(227, 0x189acdbd))
            mstore(memoryPointer, shl(228, 0x05414dff))
            mstore(add(memoryPointer, 4), uniqueSalt)
            let success := staticcall(
                gas(),
                0x6396ff2a80c067f99b3d2ab4df24,
                memoryPointer,
                36,
                memoryPointer,
                32
            )
            if iszero(success) {
                mstore(0x00, 0x3204506f) // `CallFailed()`.
                revert(0x00, 0x20)
            }
            walletAddress := mload(memoryPointer)
        }
    }

    function generateUniqueSalt(
        address owner,
        uint256 salt
    ) internal view returns (bytes32 generatedSalt) {
        assembly {
            let currentUniqueSalt := salt
            let currentContractAddress := shr(96, address())
            switch or(
                eq(shr(96, currentUniqueSalt), 0),
                eq(shr(96, currentUniqueSalt), currentContractAddress)
            )
            case 1 {
                generatedSalt := currentUniqueSalt
            }
            default {
                let memoryPointer := add(address(), 20)
                mstore(memoryPointer, owner)
                mstore(add(memoryPointer, 52), salt)
                generatedSalt := keccak256(memoryPointer, 72)
            }
        }
    }

    function addStake(uint32 unstakeDelaySec) external payable {
        assembly {
            let memoryPointer := mload(0x40)
            calldatacopy(memoryPointer, 0, 0x24)
            let success := call(
                gas(),
                0x5FF137D4b0FDCD49DcA30c7CF57E578a026d2789,
                callvalue(),
                memoryPointer,
                0x24,
                0,
                0
            )
            if iszero(success) {
                mstore(0x00, 0x3204506f) // `CallFailed()`.
                revert(0x00, 0x20)
            }
        }
    }
}
