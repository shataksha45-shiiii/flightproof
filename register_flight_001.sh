#!/bin/bash
# Registers sample_logs/flight_001.csv onchain. Run from the project folder.
set -a; source .env; set +a
cast send 0x1C8E7473272b7879d6e20494c8a04D3eB46de00e \
  "registerLog(bytes32,bytes)" 0xe79bb3a54bca5366b6c7f830f429026c87fe92ed25034c750e4afaa9cb017b38 0x33c7f7ff4ab9bebbae1da3f9062498fdd1839d7538eb8ec98c31527074a7c5e5694a47d0af725e7844e8a8f93eb7fc0017d351a75ef58ca5e1f072ba2ce1ae671c \
  --rpc-url base_sepolia --private-key "$PRIVATE_KEY"
