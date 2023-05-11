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
    // allowances (mapping owner address with spender address which is mapped with tokens approved to spend)
    mapping(address => mapping(address => uint256)) public allowance;

    event Transfer(
        address indexed from, 
        address indexed to, 
        uint256 value
    );

    event Approval(
        address indexed owner,
        address indexed spender,
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

        _transfer(msg.sender, _to, _value);

        return true;
    }

    function _transfer(
        address _from,
        address _to,
        uint256 _value
    ) internal {
        require(_to != address(0));

        // Deduct token from spender 
        balanceOf[_from] = balanceOf[_from] - _value;
        // Credits token to receiver
        balanceOf[_to] = balanceOf[_to] + _value;

        //Emit Event
        emit Transfer(_from, _to, _value);
    }


    function approve(address _spender, uint256 _value) 
        public 
        returns (bool success)
    {
        require(_spender != address(0), 'Address cannot be zero');
        allowance[msg.sender][_spender] = _value;

        emit Approval(msg.sender, _spender, _value);
        return true;
    }

    function transferFrom(address _from, address _to, uint256 _value) 
        public 
        returns (bool success)
    {
        // value is less then available value 
        require(_value <= balanceOf[_from], 'Insufficient Balance');
        // value is less then the allowed value
        require(_value <= allowance[_from][msg.sender], 'Exceeded the allowed value');

        // once we have spent the value now we decrease 'value' from allowance
        // it is to avoid double spending
        allowance[_from][msg.sender] = allowance[_from][msg.sender] - _value;

        _transfer(_from, _to, _value);

        return true;
    }

}
