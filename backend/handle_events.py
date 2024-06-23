import json
import os
import requests
from web3 import Web3
from websockets import connect
import asyncio
import warnings
from dotenv import load_dotenv

load_dotenv()

INFURA_KEY = os.getenv('INFURA_KEY')
AIRVAULT_ADDRESS = os.getenv('AIRVAULT_ADDRESS')
ETHERSCAN_API_KEY = os.getenv('ETHERSCAN_API_KEY')

# add your blockchain connection information
events = []
infura_url = 'https://sepolia.infura.io/v3/' + INFURA_KEY
w3 = Web3(Web3.HTTPProvider(infura_url))
contract_address = Web3.to_checksum_address(AIRVAULT_ADDRESS)
etherscan_url = f'https://api-sepolia.etherscan.io/api?module=contract&action=getabi&address={contract_address}&apikey={ETHERSCAN_API_KEY}'

# contract ABI extraction via Etherscan API
etherscan_response = requests.get(etherscan_url)
etherscan_content = etherscan_response.json()
contract_abi = etherscan_content.get("result")
contract_abi_dict = json.loads(contract_abi)
print(f"ABI: {contract_abi}")

users = set()

# Event name extraction
for i, j in enumerate(contract_abi_dict):
    if contract_abi_dict[i]['type'] == "event":
        events.append(contract_abi_dict[i]['name'])
        print(contract_abi_dict[i]['name'])

contract = w3.eth.contract(address=contract_address, abi=contract_abi)
block_filter = w3.eth.filter({'fromBlock': 'latest', 'address': contract_address})

def handle_events(event):
    for x, y in enumerate(events):
        # warning functions need to be set to ignore UserWarning, otherwise it will pop up in the program every time emited event name missmatches
        # the event put into "message_event" variable from "events" list
        with warnings.catch_warnings():
            warnings.simplefilter("ignore")
            # message_event gets tried by all event names until the content matches the event name
            message_event = eval(f"contract.events.{events[x]}()")
            receipt = w3.eth.wait_for_transaction_receipt(event['transactionHash'])
            result = message_event.process_receipt(receipt)
            try:
                # If the event name picked from events list matches the event name emited. It will successfully store the information in "result"
                # variable and print it out.
                print(f"Result from event {events[x]}: {result[0]['args']}")
                if events[x] == 'Deposit':
                    # Should add user to the list where users are stored
                    users.add(result[0]['args']['user'])
                if events[x] == 'Withdraw':
                    # Should remove user from the list where users are stored if his deposit amount is equal to 0
                    amount = contract.functions.lockedBalances(Web3.to_checksum_address(result[0]['args']['user'])).call()
                    if amount == 0:
                        users.remove(result[0]['args']['user'])
                break
            except IndexError as e:
                # If the event name picked from events list missmatched the event name actually emited, no content will be stored into the "result"
                # variable and when attempting to print out the result above, it will get an IndexError exception.
                print(e)

def log_loop(event_filter):
    entries = event_filter.get_new_entries()
    # When message is successfully received and log_loop method is triggered, "event_filter.get_new_entries()" does not catch the message
    # successfully on first attempt and remains empty and skips the for loop. This is why there is the infinite loop bellow, which repeats
    # the "event_filter.get_new_entries()" until it catches the message so that it can proceed and decode the transaction receipt and
    # get the events
    while True:
        if len(entries) == 0:
            entries = event_filter.get_new_entries()
            print(f"Length is Zero!!")
            continue
        else:
            print("Passed")
            break
    # print(f"event_filter_length: {entries}")
    for event in entries:
        handle_events(event)
        # print(f"event_filter: {event_filter}, event: {event}")
        print("")

# Main function that is run asynchronously and independently of the rest of the program
async def get_event():
    global block_filter
    # Initiates the connection between your dapp and the network
    async with connect("wss://sepolia.infura.io/ws/v3/" + INFURA_KEY) as ws:
        await ws.send(json.dumps({"id": 1, "method": "eth_subscribe", "params": ["logs", {"address": [f'{contract_address}']}]}))
        # Wait for the subscription completion.
        subscription_response = await ws.recv()
        print(f"Subscription response: {subscription_response}")
        while True:
            try:
                # Wait for the message in websockets and print the contents.
                await asyncio.wait_for(ws.recv(), timeout=300)
                log_loop(block_filter)
            except asyncio.exceptions.TimeoutError:
                block_filter = w3.eth.filter({'fromBlock': 'latest', 'address': contract_address})
                print('Block filter has been reset')
            except ValueError as e:
                print(e)

if __name__ == "__main__":
    loop = asyncio.new_event_loop()
    loop.run_until_complete(get_event())