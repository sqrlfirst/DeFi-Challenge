from web3 import Web3

# Replace with your provider URL (e.g., Infura, Alchemy)
infura_url = "YOUR_INFURA_URL"

# Replace with your deployed contract address
contract_address = "YOUR_CONTRACT_ADDRESS"

# Replace with the ABI (Application Binary Interface) of your contract
# You can get this from your contract source code or verification tool
abi = [
    # ... your contract ABI definition here ...
]

# Connect to the blockchain node
w3 = Web3(Web3.HTTPProvider(infura_url))

# Get the contract object
contract = w3.eth.contract(address=contract_address, abi=abi)

# Define the specific event you want to listen for
# Replace "MyEvent" with the actual event name from your contract
event_to_watch = contract.events.MyEvent

# Create a filter to listen for new events (from latest block)
event_filter = event_to_watch.createFilter(fromBlock="latest")

def handle_event(event):
  # Print event details (arguments)
  print(f"Event occurred: {event.args}")

# Continuously poll for new events
while True:
  for event in event_filter.get_new_entries():
    handle_event(event)
  # Adjust polling interval as needed (seconds)
  w3.eth.sleep(10)
