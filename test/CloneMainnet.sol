// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.15;

import "forge-std/Test.sol";
import "../interfaces/ICheatCodes.sol";

//This contract fork mainnet and use cheatcodes
contract CloningMainnet {
  event Log(string _msg, uint256 _value);

  //Import cheat code for mainnet
  CheatCodes cheats = CheatCodes(0x7109709ECfa91a80626fF3989D68f67F5b1DD12D);

   function setUp() public {
        //Fork from chain at blocknumber of attack and select blocknumber
        cheats.createSelectFork("mainnet", 16029969); 
    }

}