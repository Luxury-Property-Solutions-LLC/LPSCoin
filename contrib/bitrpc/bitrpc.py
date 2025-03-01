#!/usr/bin/env python3

import sys
import getpass
import json
import requests
from typing import Optional, Dict, Any

# ===== BEGIN USER SETTINGS =====
# Set these to avoid password prompts; otherwise, you'll be prompted per command
RPC_USER = ""
RPC_PASS = ""
RPC_HOST = "127.0.0.1"
RPC_PORT = 53473
# ====== END USER SETTINGS =====

class BitRPC:
    def __init__(self, user: str = RPC_USER, password: str = RPC_PASS, host: str = RPC_HOST, port: int = RPC_PORT):
        """Initialize RPC connection to lpscoinsd."""
        self.url = f"http://{host}:{port}"
        self.auth = (user, password) if user and password else None
        self.headers = {"Content-Type": "application/json"}
        self.id = 0

    def call(self, method: str, params: list = None) -> Any:
        """Make an RPC call to lpscoinsd."""
        self.id += 1
        payload = {
            "jsonrpc": "1.0",
            "id": self.id,
            "method": method,
            "params": params or []
        }
        try:
            response = requests.post(self.url, headers=self.headers, data=json.dumps(payload), auth=self.auth)
            response.raise_for_status()
            result = response.json()
            if "error" in result and result["error"] is not None:
                raise Exception(f"RPC Error: {result['error']}")
            return result["result"]
        except requests.RequestException as e:
            raise Exception(f"Network error: {e}")
        except Exception as e:
            raise Exception(f"RPC call failed: {e}")

def prompt_input(prompt: str, optional: bool = False) -> Optional[str]:
    """Prompt user for input, returning None if optional and empty."""
    value = input(f"{prompt}: ").strip()
    return value if value or not optional else None

def prompt_passphrase(prompt: str) -> str:
    """Prompt for a passphrase securely."""
    return getpass.getpass(prompt=prompt)

def main():
    # Check for command
    if len(sys.argv) < 2:
        print("Usage: python bitrpc.py <command> [arguments]")
        print("Run 'python bitrpc.py help' for available commands.")
        sys.exit(1)

    # Initialize RPC client
    user = RPC_USER or prompt_input("RPC username")
    password = RPC_PASS or prompt_passphrase("RPC password")
    rpc = BitRPC(user=user, password=password)

    cmd = sys.argv[1].lower()
    try:
        if cmd == "backupwallet":
            path = prompt_input("Enter destination path/filename")
            print(rpc.call("backupwallet", [path]))

        elif cmd == "encryptwallet":
            pwd = prompt_passphrase("Enter passphrase")
            pwd2 = prompt_passphrase("Repeat passphrase")
            if pwd != pwd2:
                print("Error: Passphrases do not match")
                sys.exit(1)
            print(rpc.call("encryptwallet", [pwd]))
            print("Wallet encrypted. Server stopping; restart to use encrypted wallet.")

        elif cmd == "getaccount":
            addr = prompt_input("Enter a Bitcoin address")
            print(rpc.call("getaccount", [addr]))

        elif cmd == "getaccountaddress":
            acct = prompt_input("Enter an account name")
            print(rpc.call("getaccountaddress", [acct]))

        elif cmd == "getaddressesbyaccount":
            acct = prompt_input("Enter an account name")
            print(rpc.call("getaddressesbyaccount", [acct]))

        elif cmd == "getbalance":
            acct = prompt_input("Enter an account", optional=True)
            mc = prompt_input("Minimum confirmations", optional=True)
            params = [acct, int(mc)] if acct and mc else [acct] if acct else []
            print(rpc.call("getbalance", params))

        elif cmd == "getblockbycount":
            height = prompt_input("Height")
            print(rpc.call("getblockbycount", [int(height)]))

        elif cmd == "getblockcount":
            print(rpc.call("getblockcount"))

        elif cmd == "getblocknumber":
            print(rpc.call("getblocknumber"))

        elif cmd == "getconnectioncount":
            print(rpc.call("getconnectioncount"))

        elif cmd == "getdifficulty":
            print(rpc.call("getdifficulty"))

        elif cmd == "getgenerate":
            print(rpc.call("getgenerate"))

        elif cmd == "gethashespersec":
            print(rpc.call("gethashespersec"))

        elif cmd == "getinfo":
            print(rpc.call("getinfo"))

        elif cmd == "getnewaddress":
            acct = prompt_input("Enter an account name", optional=True)
            print(rpc.call("getnewaddress", [acct] if acct else []))

        elif cmd == "getreceivedbyaccount":
            acct = prompt_input("Enter an account", optional=True)
            mc = prompt_input("Minimum confirmations", optional=True)
            params = [acct, int(mc)] if acct and mc else [acct] if acct else []
            print(rpc.call("getreceivedbyaccount", params))

        elif cmd == "getreceivedbyaddress":
            addr = prompt_input("Enter a Bitcoin address", optional=True)
            mc = prompt_input("Minimum confirmations", optional=True)
            params = [addr, int(mc)] if addr and mc else [addr] if addr else []
            print(rpc.call("getreceivedbyaddress", params))

        elif cmd == "gettransaction":
            txid = prompt_input("Enter a transaction ID")
            print(rpc.call("gettransaction", [txid]))

        elif cmd == "getwork":
            data = prompt_input("Data", optional=True)
            print(rpc.call("getwork", [data] if data else []))

        elif cmd == "help":
            cmd_help = prompt_input("Command", optional=True)
            print(rpc.call("help", [cmd_help] if cmd_help else []))

        elif cmd == "listaccounts":
            mc = prompt_input("Minimum confirmations", optional=True)
            print(rpc.call("listaccounts", [int(mc)] if mc else []))

        elif cmd == "listreceivedbyaccount":
            mc = prompt_input("Minimum confirmations", optional=True)
            incemp = prompt_input("Include empty? (true/false)", optional=True)
            params = [int(mc), incemp.lower() == "true"] if mc and incemp else [int(mc)] if mc else []
            print(rpc.call("listreceivedbyaccount", params))

        elif cmd == "listreceivedbyaddress":
            mc = prompt_input("Minimum confirmations", optional=True)
            incemp = prompt_input("Include empty? (true/false)", optional=True)
            params = [int(mc), incemp.lower() == "true"] if mc and incemp else [int(mc)] if mc else []
            print(rpc.call("listreceivedbyaddress", params))

        elif cmd == "listtransactions":
            acct = prompt_input("Account", optional=True)
            count = prompt_input("Number of transactions", optional=True)
            frm = prompt_input("Skip", optional=True)
            params = [acct, int(count), int(frm)] if acct and count and frm else [acct] if acct else []
            print(rpc.call("listtransactions", params))

        elif cmd == "move":
            frm = prompt_input("From")
            to = prompt_input("To")
            amt = float(prompt_input("Amount"))
            mc = prompt_input("Minimum confirmations", optional=True)
            comment = prompt_input("Comment", optional=True)
            params = [frm, to, amt, int(mc), comment] if mc and comment else [frm, to, amt, int(mc)] if mc else [frm, to, amt]
            print(rpc.call("move", params))

        elif cmd == "sendfrom":
            frm = prompt_input("From")
            to = prompt_input("To")
            amt = float(prompt_input("Amount"))
            mc = prompt_input("Minimum confirmations", optional=True)
            comment = prompt_input("Comment", optional=True)
            commentto = prompt_input("Comment-to", optional=True)
            params = [frm, to, amt, int(mc), comment, commentto] if mc and comment and commentto else [frm, to, amt]
            print(rpc.call("sendfrom", params))

        elif cmd == "sendmany":
            frm = prompt_input("From")
            to = prompt_input("To (format: address1:amount1,address2:amount2,...)")
            amounts = dict(pair.split(":") for pair in to.split(","))
            mc = prompt_input("Minimum confirmations", optional=True)
            comment = prompt_input("Comment", optional=True)
            params = [frm, amounts, int(mc), comment] if mc and comment else [frm, amounts]
            print(rpc.call("sendmany", params))

        elif cmd == "sendtoaddress":
            to = prompt_input("To")
            amt = float(prompt_input("Amount"))
            comment = prompt_input("Comment", optional=True)
            commentto = prompt_input("Comment-to", optional=True)
            params = [to, amt, comment, commentto] if comment and commentto else [to, amt]
            print(rpc.call("sendtoaddress", params))

        elif cmd == "setaccount":
            addr = prompt_input("Address")
            acct = prompt_input("Account")
            print(rpc.call("setaccount", [addr, acct]))

        elif cmd == "setgenerate":
            gen = prompt_input("Generate? (true/false)")
            cpus = prompt_input("Max processors/cores (-1 for unlimited)", optional=True)
            params = [gen.lower() == "true", int(cpus)] if cpus else [gen.lower() == "true"]
            print(rpc.call("setgenerate", params))

        elif cmd == "settxfee":
            amt = float(prompt_input("Amount"))
            print(rpc.call("settxfee", [amt]))

        elif cmd == "stop":
            print(rpc.call("stop"))

        elif cmd == "validateaddress":
            addr = prompt_input("Address")
            print(rpc.call("validateaddress", [addr]))

        elif cmd == "walletpassphrase":
            pwd = prompt_passphrase("Enter wallet passphrase")
            print(rpc.call("walletpassphrase", [pwd, 60]))
            print("Wallet unlocked")

        elif cmd == "walletpassphrasechange":
            pwd = prompt_passphrase("Enter old wallet passphrase")
            pwd2 = prompt_passphrase("Enter new wallet passphrase")
            print(rpc.call("walletpassphrasechange", [pwd, pwd2]))
            print("Passphrase changed")

        else:
            print(f"Error: Command '{cmd}' not found or not supported")
            print("Run 'python bitrpc.py help' for available commands.")
            sys.exit(1)

    except Exception as e:
        print(f"Error: {e}")
        sys.exit(1)

if __name__ == "__main__":
    main()
