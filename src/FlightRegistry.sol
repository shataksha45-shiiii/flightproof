// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import {ECDSA} from "@openzeppelin/contracts/utils/cryptography/ECDSA.sol";
import {MessageHashUtils} from "@openzeppelin/contracts/utils/cryptography/MessageHashUtils.sol";

contract FlightRegistry {
    struct Record {
        address signer;
        uint256 timestamp;
    }

    mapping(bytes32 => Record) public records;

    event LogRegistered(bytes32 indexed logHash, address indexed signer, uint256 timestamp);

    function registerLog(bytes32 logHash, bytes calldata signature) external {
        require(records[logHash].timestamp == 0, "Already registered");

        bytes32 digest = MessageHashUtils.toEthSignedMessageHash(logHash);
        address signer = ECDSA.recover(digest, signature);

        records[logHash] = Record(signer, block.timestamp);
        emit LogRegistered(logHash, signer, block.timestamp);
    }

    function isRegistered(bytes32 logHash) external view returns (bool) {
        return records[logHash].timestamp != 0;
    }
}
