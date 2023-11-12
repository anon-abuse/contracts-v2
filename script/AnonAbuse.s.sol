// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.17;

import "forge-std/Script.sol";
import "../contracts/AnonAbuse.sol";
import "../tests/lib/Loader.sol";
import {BonsaiRelay} from "bonsai/BonsaiRelay.sol";
import {IRiscZeroVerifier} from "bonsai/IRiscZeroVerifier.sol";
import {ControlID, RiscZeroGroth16Verifier} from "bonsai/groth16/RiscZeroGroth16Verifier.sol";

contract AnonAbuseScript is Script, Loader {

    UserData[] public userDatas;
    AnonAbuse public anonAbuse;
    BonsaiRelay private bonsaiVerifyingRelay;
    address attackerAddress;

    uint256 constant NUM_ADDRESS = 8;

    function setUp() public {
        IRiscZeroVerifier verifier = new RiscZeroGroth16Verifier(ControlID.CONTROL_ID_0, ControlID.CONTROL_ID_1);
        bonsaiVerifyingRelay = new BonsaiRelay(verifier);
        anonAbuse = new AnonAbuse(bonsaiVerifyingRelay);

        string memory root = vm.projectRoot();
        for (uint i = 0; i < NUM_ADDRESS; i++) {
            userDatas.push(loadUserData(root, i));
        }

        attackerAddress = randomHackerAddress();
    }

    function run() public {

        fundAttackedAddressPreAttack();

        logBalances("pre-attack state");

        drainAttackedAddress();

        logBalances("post-attack state");

        vm.startBroadcast();

        populateContractStructure();

        vm.stopBroadcast();
    }


    function fundAttackedAddressPreAttack() public {
        for (uint i = 0; i < NUM_ADDRESS; i++) {
            vm.deal(userDatas[i].compressedPublicKey, 1 ether);
        }
    }

    function drainAttackedAddress() public {
        for (uint i = 0; i < NUM_ADDRESS; i++) {
            vm.prank(userDatas[i].compressedPublicKey);
            address targetAddress = address(0x00000000000000000000);
            payable(targetAddress).transfer(1 ether);
        }
    }

    function randomHackerAddress() internal view returns (address) {
        // Generate a random uint256 and cast it to an address
        return address(uint160(uint(keccak256(abi.encodePacked(block.timestamp, block.difficulty, block.coinbase, block.number, msg.sender)))));
    }

    function populateContractStructure() public {
        for (uint i = 0; i < NUM_ADDRESS; i++) {
            address currentHackedAddress = userDatas[i].compressedPublicKey;
            bytes32 groupMerkleRoot = keccak256(abi.encodePacked(block.timestamp, block.difficulty, currentHackedAddress));
            address zeroAddress = address(0x00000000000000000000);
            anonAbuse.entryPoint(groupMerkleRoot, zeroAddress, currentHackedAddress);
        }
    }

    function logBalances(string memory state) public {
        for (uint i = 0; i < NUM_ADDRESS; i++) {
            // Retrieve the balance of each address
            uint balance = userDatas[i].compressedPublicKey.balance;

            // Log the balance to the console
            console.log(state);
            console.log("Address:", userDatas[i].compressedPublicKey);
            console.log("Balance:", balance);
        }
    }
}
