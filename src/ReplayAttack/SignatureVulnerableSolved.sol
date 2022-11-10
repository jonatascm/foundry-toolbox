// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import "@openzeppelin/contracts/utils/Address.sol";

/**
  Signature Replay Attack Vulenrability
  Don't use this contract in production, it contains a vulnerability
  The comments are showing how to fix the vulnerability
 */
contract SignatureVulnerableSolved {
  using Address for address payable;
  address[2] public owners;
  mapping(bytes32 => bool) executed;

  struct Signature {
    uint8 v;
    bytes32 r;
    bytes32 s;
  }

  constructor(address[2] memory _owners) {
    owners = _owners;
  }

  function transfer(
    address to,
    uint256 amount,
    uint256 nonce,
    Signature[2] memory signatures
  ) external {
    (bytes32 txhash1, address sign1) = verifySignature(to, amount, nonce, signatures[0]);
    (bytes32 txhash2, address sign2) = verifySignature(to, amount, nonce, signatures[1]);

    //Check if already executed
    require(!executed[txhash1] && !(executed[txhash2]), "Signature expired");
    executed[txhash1] = true;
    executed[txhash2] = true;

    payable(to).sendValue(amount);
  }

  function verifySignature(
    address to,
    uint256 amount,
    uint256 nonce,
    Signature memory signature
  ) public returns (bytes32 messageHash, address signer) {
    // 52 = message length
    string memory header = "\x19Ethereum Signed Message:\n52";

    // Perform the elliptic curve recover operation
    messageHash = keccak256(abi.encodePacked(address(this), header, to, amount, nonce));

    signer = ecrecover(messageHash, signature.v, signature.r, signature.s);
  }

  receive() external payable {}
}