pragma solidity ^0.8.19;

interface IEntryPoint {
    event AccountDeployed(
        bytes32 indexed userOpHash,
        address indexed sender,
        address factory,
        address paymaster
    );
    event BeforeExecution();
    event Deposited(address indexed account, uint256 totalDeposit);
    event SignatureAggregatorChanged(address indexed aggregator);
    event StakeLocked(
        address indexed account,
        uint256 totalStaked,
        uint256 unstakeDelaySec
    );
    event StakeUnlocked(address indexed account, uint256 withdrawTime);
    event StakeWithdrawn(
        address indexed account,
        address withdrawAddress,
        uint256 amount
    );
    event UserOperationEvent(
        bytes32 indexed userOpHash,
        address indexed sender,
        address indexed paymaster,
        uint256 nonce,
        bool success,
        uint256 actualGasCost,
        uint256 actualGasUsed
    );
    event UserOperationRevertReason(
        bytes32 indexed userOpHash,
        address indexed sender,
        uint256 nonce,
        bytes revertReason
    );
    event Withdrawn(
        address indexed account,
        address withdrawAddress,
        uint256 amount
    );

    struct MemoryUserOp {
        address sender;
        uint256 nonce;
        uint256 callGasLimit;
        uint256 verificationGasLimit;
        uint256 preVerificationGas;
        address paymaster;
        uint256 maxFeePerGas;
        uint256 maxPriorityFeePerGas;
    }

    struct UserOpInfo {
        MemoryUserOp mUserOp;
        bytes32 userOpHash;
        uint256 prefund;
        uint256 contextOffset;
        uint256 preOpGas;
    }

    struct UserOpsPerAggregator {
        UserOperation[] userOps;
        address aggregator;
        bytes signature;
    }

    struct DepositInfo {
        uint112 deposit;
        bool staked;
        uint112 stake;
        uint32 unstakeDelaySec;
        uint48 withdrawTime;
    }

    struct UserOperation {
        address sender;
        uint256 nonce;
        bytes initCode;
        bytes callData;
        uint256 callGasLimit;
        uint256 verificationGasLimit;
        uint256 preVerificationGas;
        uint256 maxFeePerGas;
        uint256 maxPriorityFeePerGas;
        bytes paymasterAndData;
        bytes signature;
    }

    function SIG_VALIDATION_FAILED() external view returns (uint256);

    function _validateSenderAndPaymaster(
        bytes memory initCode,
        address sender,
        bytes memory paymasterAndData
    ) external view;

    function addStake(uint32 unstakeDelaySec) external payable;

    function balanceOf(address account) external view returns (uint256);

    function depositTo(address account) external payable;

    function deposits(
        address
    )
        external
        view
        returns (
            uint112 deposit,
            bool staked,
            uint112 stake,
            uint32 unstakeDelaySec,
            uint48 withdrawTime
        );

    function getDepositInfo(
        address account
    ) external view returns (DepositInfo memory info);

    function getNonce(
        address sender,
        uint192 key
    ) external view returns (uint256 nonce);

    function getSenderAddress(bytes memory initCode) external;

    function getUserOpHash(
        UserOperation memory userOp
    ) external view returns (bytes32);

    function handleAggregatedOps(
        UserOpsPerAggregator[] memory opsPerAggregator,
        address beneficiary
    ) external;

    function handleOps(
        UserOperation[] memory ops,
        address beneficiary
    ) external;

    function incrementNonce(uint192 key) external;

    function innerHandleOp(
        bytes memory callData,
        UserOpInfo memory opInfo,
        bytes memory context
    ) external returns (uint256 actualGasCost);

    function nonceSequenceNumber(
        address,
        uint192
    ) external view returns (uint256);

    function simulateHandleOp(
        UserOperation memory op,
        address target,
        bytes memory targetCallData
    ) external;

    function simulateValidation(UserOperation memory userOp) external;

    function unlockStake() external;

    function withdrawStake(address withdrawAddress) external;

    function withdrawTo(
        address withdrawAddress,
        uint256 withdrawAmount
    ) external;
}
