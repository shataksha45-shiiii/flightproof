#!/bin/bash
# Usage: tools/check_log.sh <logfile>
# Hashes the file, asks the FlightRegistry contract about that hash, prints ✅ or ❌.
CONTRACT=$(cat deployed_address.txt)
FILE="$1"
HASH=$(cast keccak 0x$(xxd -p "$FILE" | tr -d '\n'))
OUT=$(cast call "$CONTRACT" "records(bytes32)(address,uint256)" "$HASH" --rpc-url base_sepolia)
SIGNER=$(echo "$OUT" | sed -n 1p | awk '{print $1}')
TS=$(echo "$OUT" | sed -n 2p | awk '{print $1}')
echo "file : $FILE"
echo "hash : $HASH"
if [ "$TS" = "0" ]; then
  echo "❌ NOT registered onchain (file was never anchored, or it was edited)"
else
  echo "✅ MATCHES the onchain record"
  echo "   signed by : $SIGNER"
  echo "   registered: $(date -r "$TS" 2>/dev/null || date -d @"$TS")"
fi
