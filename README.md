# DeFi-Challenge

[Challenge](./CHALLENGE.md)

## Contracts

There are 3 contracts in total, they are in [/contracts](./contracts/) folders. The project is build using [Foundry](https://book.getfoundry.sh/) instructions how to run the project can be found in SC [README.md](./contracts/README.md).


### Deploy on Sepolia testnet

- [AirVault](https://sepolia.etherscan.io/address/0xa76934f3312b456b17c5ab0ecb59cb2fa844b6d2)
- [FUD](https://sepolia.etherscan.io/address/0xa87ef6178c32ea6c7eb458b6276df4a1e497076a)
- [WIN](https://sepolia.etherscan.io/address/0x2f64fdec4119a1a06e496474f04f1f63e64f69b6)

## Backend

Backend part of project is in [/backend](./backend/) folder.

Backend is listening contract 2 contracts events:

- Deposit
- Withdraw

in case if user has deposit, backend should mint WIN tokens to user account.

## Further improvements

As backend in the design proposed by challenge is element of system centralization, design of the system can be improved by moving functionality of token distrbution to the on-chain part. Also as backend in the design was responsible for token minting that means that fees are increasing linearly with number of users.
