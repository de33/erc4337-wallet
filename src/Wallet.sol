pragma solidity ^0.8.19;

import {ECDSA} from "solady/src/utils/ECDSA.sol";
import {Ownable} from "solady/src/auth/Ownable.sol";
import {IAccount} from "./interfaces/IAccount.sol";

contract Wallet is Ownable, IAccount {
    using ECDSA for bytes32;

    address internal constant ENTRYPOINT =
        0x5FF137D4b0FDCD49DcA30c7CF57E578a026d2789;

    bytes4 internal constant WALLET_OWNER_SLOT_NOT = 0x8b78c6d8;

    error CallFailed();
    error AlreadyInitialized();

    function entryPoint() public pure returns (address) {
        return ENTRYPOINT;
    }

    function isOwnerOrEntryPoint() internal view {
        assembly {
            let owner_ := sload(not(0x8b78c6d8))
            if iszero(or(eq(caller(), owner_), eq(caller(), ENTRYPOINT))) {
                mstore(0x00, 0x82b42900) // `Unauthorized()`.
                revert(0x1c, 0x04)
            }
        }
    }

    function isEntryPoint() internal view {
        assembly {
            if iszero(eq(caller(), ENTRYPOINT)) {
                mstore(0x00, 0x82b42900)
                revert(0x1c, 0x04)
            }
        }
    }

    function validateUserOp(
        UserOperation calldata userOp,
        bytes32 userOpHash,
        uint256 missingAccountFunds
    ) external returns (uint256 validationData) {
        isEntryPoint();
        validationData = _validateSignature(userOp, userOpHash);
        _payPrefund(missingAccountFunds);
    }

    function getNonce() public view virtual returns (uint256 nonce) {
        assembly {
            mstore(0x40, 0x35567e1a) // `getNonce(address,uint192)`.
            mstore(0x60, address())
            mstore(0x80, 0)
            let success := staticcall(gas(), ENTRYPOINT, 0x5c, 0x44, 0x40, 0x20)
            if iszero(success) {
                mstore(0x00, 0x3204506f) // `CallFailed()`.
                revert(0x1c, 0x04)
            }
            nonce := mload(0x40)
        }
    }

    function _validateSignature(
        UserOperation calldata userOp,
        bytes32 userOpHash
    ) internal virtual returns (uint256 validationData) {
        bytes32 hash = userOpHash.toEthSignedMessageHash();
        if (owner() != hash.recover(userOp.signature)) return 1;
        return 0;
    }

    function _call(address target, uint256 value, bytes memory data) internal {
        assembly {
            let success := call(
                gas(),
                target,
                value,
                add(data, 0x20),
                mload(data),
                0,
                0
            )
            if iszero(success) {
                mstore(0x00, 0x3204506f) // `CallFailed()`.
                revert(0x1c, 0x04)
            }
        }
    }

    function initialize(address anOwner) external {
        assembly {
            if sload(not(0x8b78c6d8)) {
                mstore(0x00, 0x0dc149f0) // `AlreadyInitialized()`.
                revert(0x1c, 0x04)
            }
        }
        _initializeOwner(anOwner);
    }

    function execute(
        address dest,
        uint256 value,
        bytes calldata func
    ) external {
        isOwnerOrEntryPoint();
        _call(dest, value, func);
    }

    function _payPrefund(uint256 missingAccountFunds) internal virtual {
        if (missingAccountFunds != 0) {
            assembly {
                let success := call(
                    0xffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff,
                    caller(),
                    missingAccountFunds,
                    0,
                    0,
                    0,
                    0
                )
                if iszero(success) {
                    mstore(0x00, 0x3204506f) // `CallFailed()`.
                    revert(0x1c, 0x04)
                }
            }
        }
    }

    function onERC721Received(
        address,
        address,
        uint256,
        bytes calldata
    ) external pure returns (bytes4 result) {
        assembly {
            result := 0x150b7a02 // onERC721Received(address,address,uint256,bytes)
        }
    }

    function onERC1155Received(
        address,
        address,
        uint256,
        uint256,
        bytes calldata
    ) external pure returns (bytes4 result) {
        assembly {
            result := 0xf23a6e61 // onERC1155Received(address,address,uint256,uint256,bytes)
        }
    }

    function onERC1155BatchReceived(
        address,
        address,
        uint256[] calldata,
        uint256[] calldata,
        bytes calldata
    ) external pure returns (bytes4 result) {
        assembly {
            result := 0xbc197c81 // onERC1155BatchReceived(address,address,uint256[],uint256[],bytes)
        }
    }

    receive() external payable {}
}
