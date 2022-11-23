// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.15;

import "forge-std/Test.sol";
import "./interfaces/ICheatCodes.sol";

/**
  Pickle Finance - Evil Jar Attack
  Lost: $20 million
  Necessary Info:
  Attacker : 0xbac8a476b95ec741e56561a66231f92bc88bb3a8
  AttackContract : 0x2b0b02ce19c322b4dd55a3949b4fb6e9377f7913#code
  Attack TX: https://etherscan.io/tx/0xe72d4e7ba9b5af0cf2a8cfb1e30fd9f388df0ab3da79790be842bfbed11087b0
  Attack TX: https://ethtx.info/mainnet/0xe72d4e7ba9b5af0cf2a8cfb1e30fd9f388df0ab3da79790be842bfbed11087b0
  Exploit code refers to sam. https://github.com/banteg/evil-jar/blob/master/reference/samczsun.sol
 */
contract PickleFinance {
  event Log(string _msg, uint256 _value);

  CheatCodes cheats = CheatCodes(0x7109709ECfa91a80626fF3989D68f67F5b1DD12D);

   function setUp() public {
        //Fork from chain at blocknumber of attack
        cheats.createSelectFork("mainnet", 16029969); 
    }

}