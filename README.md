# ERC-4337 Compliant Account Abstraction Wallet and Factory

This project is a work in progress, aiming to create an ERC-4337 compliant account abstraction wallet and a factory from which to deploy them. The implementation heavily relies on inline assembly for efficiency and direct control over the EVM.

The wallet contract provides the functionality of a basic Ethereum smart contract wallet but with additional features defined by the ERC-4337 standard. The factory contract is used to deploy new instances of the wallet contract.

The project is inspired by the [Solady](https://github.com/Vectorized/solady) project and uses many of the library's functions.

## Testing

Testing is done using the forking feature of Foundry. This allows us to simulate the behavior of the contracts in a realistic environment, including interaction with other contracts(i.e., the EntryPoint contract) on Ethereum mainnet.

```
forge test -f <rpc_url>
```

## Progress

The basic structure of the wallet and factory contracts has been implemented, but there is still much work to be done. The next steps include implementing the full ERC-4337 interface in the wallet contract and adding more comprehensive tests.

Contributions and feedback are welcome.
