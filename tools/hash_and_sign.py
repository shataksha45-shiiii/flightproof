"""Hash a flight log and sign the hash with the drone's private key.

Usage:
    python3 tools/hash_and_sign.py <logfile>            # sign (needs PRIVATE_KEY in env or .env)
    python3 tools/hash_and_sign.py <logfile> --verify <signature> <expected_address>
"""
import json
import os
import sys

from eth_account import Account
from eth_account.messages import encode_defunct
from eth_utils import keccak


def log_hash(path: str) -> bytes:
    with open(path, "rb") as f:
        return keccak(f.read())  # the file's fingerprint (keccak256)


def load_key() -> str:
    key = os.environ.get("PRIVATE_KEY")
    if not key and os.path.exists(".env"):
        for line in open(".env"):
            if line.startswith("PRIVATE_KEY="):
                key = line.strip().split("=", 1)[1]
    if not key or "PASTE_YOUR" in key:
        sys.exit("No real PRIVATE_KEY found. Put a burner key in .env first.")
    return key


def sign(path: str) -> dict:
    h = log_hash(path)
    # Same prefix the contract adds with toEthSignedMessageHash (32-byte message)
    msg = encode_defunct(primitive=h)
    signed = Account.sign_message(msg, load_key())
    return {
        "logHash": "0x" + h.hex(),
        "signature": "0x" + signed.signature.hex().removeprefix("0x"),
        "signer": Account.recover_message(msg, signature=signed.signature),
    }


def verify(path: str, signature: str, expected: str) -> bool:
    h = log_hash(path)
    recovered = Account.recover_message(encode_defunct(primitive=h), signature=signature)
    print("recovered signer:", recovered)
    return recovered.lower() == expected.lower()


if __name__ == "__main__":
    if len(sys.argv) >= 5 and sys.argv[2] == "--verify":
        ok = verify(sys.argv[1], sys.argv[3], sys.argv[4])
        print("✅ authentic" if ok else "❌ TAMPERED or wrong signer")
    elif len(sys.argv) == 2:
        print(json.dumps(sign(sys.argv[1]), indent=2))
    else:
        sys.exit(__doc__)
