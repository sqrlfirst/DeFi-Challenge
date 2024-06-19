from web3 import Web3
from web3.eth import Account

# Replace with your provider URL (e.g., Infura, Alchemy)
infura_url = "YOUR_INFURA_URL"

# Replace with your deployed contract address
contract_address = "YOUR_CONTRACT_ADDRESS"

# Replace with the ABI (Application Binary Interface) of your contract
# You can get this from your contract source code or verification tool
abi = [
    # ... your contract ABI definition here ...
]

# Replace with your private key (ensure proper security measures)
private_key = "YOUR_PRIVATE_KEY"

# Address to receive minted tokens
recipient_address = "YOUR_RECIPIENT_ADDRESS"

# Amount to mint (convert to Wei if necessary)
mint_amount = 1000  # Adjust this value

def mint_tokens(account, contract, recipient, amount):
  """
  Calls the mint function on the ERC20 token contract.

  Args:
      account (web3.eth.Account): Web3 account object with private key.
      contract (web3.eth.Contract): ERC20 token contract object.
      recipient (str): Address to receive minted tokens.
      amount (int or str): Amount to mint (in Wei or human-readable format).
  """

  # Get gas estimate (adjust gas if needed)
  gas_estimate = contract.functions.mint(recipient, amount).estimateGas()

  # Build transaction
  tx = contract.functions.mint(recipient, amount).buildTransaction({
      'chainId': w3.eth.chain_id,
      'gas': gas_estimate,
      'nonce': w3.eth.getTransactionCount(account.address),
  })

  # Sign transaction
  signed_tx = account.signTransaction(tx)

  # Send transaction
  tx_hash = w3.eth.sendRawTransaction(signed_tx.rawTransaction)

  # Print transaction details
  print(f"Transaction sent: https://etherscan.io/tx/{tx_hash}")

# Connect to the blockchain node
w3 = Web3(Web3.HTTPProvider(infura_url))

# Get contract and account objects
account = Account.from_key(private_key)
contract = w3.eth.contract(address=contract_address, abi=abi)

# Convert amount to Wei if necessary (check your contract's decimals)
if isinstance(mint_amount, str):
  mint_amount = w3.toWei(mint_amount, 'ether')

# Call mint function
mint_tokens(account, contract, recipient_address, mint_amount)
