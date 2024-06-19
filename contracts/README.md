# AirVault contracts

## How to compile, run tests and deploy

To run the project you need Foundry to be installed, then run the following command:

`forge build`

To run the tests, use:

`forge test`

To load the variables in the `.env` file:

`source .env`

To deploy and verify contracts:

`forge script --chain sepolia script/NFT.s.sol:MyScript --rpc-url $SEPOLIA_RPC_URL --broadcast --verify -vvvv`
