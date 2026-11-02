// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import {Test} from "forge-std/Test.sol";
import {MessageHashUtils} from "@openzeppelin/contracts/utils/cryptography/MessageHashUtils.sol";
import {FlightRegistry} from "../src/FlightRegistry.sol";

contract FlightRegistryTest is Test {
    FlightRegistry registry;
    uint256 droneKey = 0xA11CE;
    address drone;

    function setUp() public {
        registry = new FlightRegistry();
        drone = vm.addr(droneKey);
    }

    function _sign(bytes32 logHash) internal view returns (bytes memory) {
        bytes32 digest = MessageHashUtils.toEthSignedMessageHash(logHash);
        (uint8 v, bytes32 r, bytes32 s) = vm.sign(droneKey, digest);
        return abi.encodePacked(r, s, v);
    }

    function test_RealLogVerifies() public {
        bytes32 logHash = keccak256("flight log: 120 m");
        registry.registerLog(logHash, _sign(logHash));

        assertTrue(registry.isRegistered(logHash));
        (address signer,) = registry.records(logHash);
        assertEq(signer, drone);
    }

    function test_TamperedLogGivesWrongSigner() public {
        bytes32 original = keccak256("flight log: 120 m");
        bytes32 tampered = keccak256("flight log: 121 m");

        registry.registerLog(tampered, _sign(original));

        (address signer,) = registry.records(tampered);
        assertTrue(signer != drone);
    }

    function test_CannotRegisterTwice() public {
        bytes32 logHash = keccak256("flight log: 120 m");
        bytes memory sig = _sign(logHash);
        registry.registerLog(logHash, sig);

        vm.expectRevert("Already registered");
        registry.registerLog(logHash, sig);
    }
}
