// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import "forge-std/Test.sol";
import "../../src/ReplayAttack/SignatureVulnerable.sol";
import "../../src/ReplayAttack/SignatureVulnerableSolved.sol";

contract ReplayAttackTest is Test {
  SignatureVulnerable vulnerableContract;
  SignatureVulnerableSolved solvedContract;

  uint256 internal alicePrivateKey;
  uint256 internal bobPrivateKey;

  address internal alice;
  address internal bob;

   struct Signature {
    uint8 v;
    bytes32 r;
    bytes32 s;
  }

  function setUp() public {
    //Setup keys
    alicePrivateKey = 0xA11CE;
    bobPrivateKey = 0xB0B;

    alice = vm.addr(alicePrivateKey);
    bob = vm.addr(bobPrivateKey);

    //Setup contract
    vulnerableContract = new SignatureVulnerable([address(alice), address(bob)]);
    solvedContract = new SignatureVulnerableSolved([address(alice), address(bob)]);

    //Add ether to contract
    uint256 amount = 2 * (10**18);
    
    (bool success, ) = address(vulnerableContract).call{value: amount}("");
    require(success, "Fail");

    (bool successSolved, ) = address(solvedContract).call{value: amount}("");
    require(successSolved, "Fail");
  }

  function testReplayAttackVulnerability() public { 
    //Setting messageHash
    string memory header = "\x19Ethereum Signed Message:\n52";
    uint256 amount = 1 * (10**18);
    
    bytes32 messageHash = keccak256(abi.encodePacked(header, bob, amount));

    //Getting alice/bob signature for transfer
    (uint8 vA, bytes32 rA, bytes32 sA) = vm.sign(alicePrivateKey, messageHash);
    (uint8 vB, bytes32 rB, bytes32 sB) = vm.sign(bobPrivateKey, messageHash);

    SignatureVulnerable.Signature memory aliceSignature = SignatureVulnerable.Signature({v: vA,r: rA,s: sA});
    SignatureVulnerable.Signature memory bobSignature = SignatureVulnerable.Signature({v: vB,r: rB,s: sB});

    vm.startPrank(bob);
    //Use the signature from bob/alice
    vulnerableContract.transfer(bob, amount, [aliceSignature, bobSignature]);
    
    //Replaying same signature from alice/bob
    vulnerableContract.transfer(bob, amount, [aliceSignature, bobSignature]);

    assertEq(address(vulnerableContract).balance, 0);
  }

  function testReplayAttackVulnerabilitySolved() public { 
    //Setting messageHash
    string memory header = "\x19Ethereum Signed Message:\n52";
    uint256 amount = 1 * (10**18);
    uint256 nonce = 1;
    
    bytes32 messageHash = keccak256(abi.encodePacked(address(solvedContract),header, bob, amount, nonce));

    //Getting alice/bob signature for transfer
    (uint8 vA, bytes32 rA, bytes32 sA) = vm.sign(alicePrivateKey, messageHash);
    (uint8 vB, bytes32 rB, bytes32 sB) = vm.sign(bobPrivateKey, messageHash);

    SignatureVulnerableSolved.Signature memory aliceSignature = SignatureVulnerableSolved.Signature({v: vA,r: rA,s: sA});
    SignatureVulnerableSolved.Signature memory bobSignature = SignatureVulnerableSolved.Signature({v: vB,r: rB,s: sB});

    vm.startPrank(bob);
    //Use the signature from bob/alice
    solvedContract.transfer(bob, amount, nonce, [aliceSignature, bobSignature]);
    
    //Try to repla same signature from alice/bob
    vm.expectRevert(abi.encodePacked("Signature expired"));
    solvedContract.transfer(bob, amount, nonce, [aliceSignature, bobSignature]);

    assertEq(address(solvedContract).balance, amount);
  }
}
