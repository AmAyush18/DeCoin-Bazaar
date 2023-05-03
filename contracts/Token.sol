// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.0;

import "hardhat/console.sol";

contract Token {
    string public name;
    string public symbol;
    uint256 public decimals = 18;
    uint256 public totalSupply;

    // Track Balances (mapping adresses with their balance)
    mapping(address => uint256) public balanceOf;

    event Transfer(
        address indexed from, 
        address indexed to, 
        uint256 value
    );

    constructor(
        string memory _name, 
        string memory _symbol, 
        uint256 _totalSupply
    ) {
        name = _name;
        symbol = _symbol;
        totalSupply = _totalSupply * (10**decimals);
        balanceOf[msg.sender] = totalSupply;   // msg is the global variable we have and .sender gives us the address of the person calling this function 
    }

    function transfer(address _to, uint256 _value) 
        public 
        returns (bool success)
    {   
        // Require that sender has enough token to spend
        require(balanceOf[msg.sender] >= _value);
        require(_to != address(0));

        // Deduct token from spender 
        balanceOf[msg.sender] = balanceOf[msg.sender] - _value;
        // Credit token to receiver
        balanceOf[_to] = balanceOf[_to] + _value;
        
        //Emit Event
        emit Transfer(msg.sender, _to, _value);

        return true;
    }
}
