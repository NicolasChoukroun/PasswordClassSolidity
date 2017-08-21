
pragma solidity ^0.4.13;

/**
 * Pass Class
 * Copyright 2017, TheWolf
 * 
 * A password class for additionnal security
 * 
 */
 
/*  Math operations with safety checks */
contract safeMath {
  function safeMul(uint a, uint b) internal constant returns (uint) {
    uint c = a * b;
    assert(a == 0 || c / a == b);
    return c;
  }

  function safeDiv(uint a, uint b) internal constant returns (uint) {
    assert(b > 0);
    uint c = a / b;
    assert(a == b * c + a % b);
    return c;
  }

  function safeSub(uint a, uint b) internal constant returns (uint) {
    assert(b <= a);
    return a - b;
  }

  function safeAdd(uint a, uint b) internal constant returns (uint) {
    uint c = a + b;
    assert(c>=a && c>=b);
    return c;
  }
}

/* owned class */
contract owned is safeMath {
    address public owner;

    function owned() {
        owner = msg.sender;
    }

    modifier onlyOwner {
        if (msg.sender != owner) revert();
        _;
    }

    function transferOwnership(address newOwner) onlyOwner {
        owner = newOwner;
    }
}

 
/* pass class */
/* *************************************************************/
// Here is the class *******************************************
/* *************************************************************/

contract pass is owned{
    bytes32 internalPass;

    function storePassword(string password)  internal onlyOwner{
        internalPass = sha256(password);
    }

    modifier protected(string password) {
        if ( internalPass!= sha256(password)) revert();
        _;
    }

    function changePassword(string oldPassword, string newPassword)  onlyOwner returns(bool) {
        if (internalPass== sha256(oldPassword)) {
            internalPass = sha256(newPassword); 
            return true;
        }
        return false;
    }
}



/* ERC20 Contract definitions */
contract ERC20 {
  uint256 public totalETHSupply; // added to the ERC20 for convenience, does not change the protocol
  function balanceOf(address who) constant returns (uint);
  function allowance(address owner, address spender) constant returns (uint);
  function transfer(address to, uint value) returns (bool ok);
  function transferFrom(address from, address to, uint value) returns (bool ok);
  function approve(address spender, uint value) returns (bool ok);
  event Transfer(address indexed from, address indexed to, uint value);
  event Approval(address indexed owner, address indexed spender, uint value);
}


/*  TEST Token Creation and Functionality */
contract TokenBase is ERC20, pass {

    uint public totalAddress;
    
    function TokenBase() { // constructor, first address is owner
        addr[0]=msg.sender;
        totalAddress=1;
    }
    
    // Send to the address _to, value money
    function transfer(address _to, uint256 _value) returns (bool success) {
      if (balances[msg.sender] >= _value) { 
        balances[msg.sender] -= _value;
        balances[_to] += _value;
        Transfer(msg.sender, _to, _value);
        return true;
      } else {
        return false;
      }
    }

    // Transfer money from one adress _from to another adress _to
    function transferFrom(address _from, address _to, uint256 _value) returns (bool success) {
      if (balances[_from] >= _value && allowed[_from][msg.sender] >= _value ) { 
        balances[_to] += _value;
        balances[_from] -= _value;
        allowed[_from][msg.sender] -= _value;
        Transfer(_from, _to, _value);
        return true;
      } else {
        return false;
      }
    }
    
    // get the current owner balance
    function balanceOf(address _owner) constant returns (uint256 balance) {
        return balances[_owner];
    }

    // transaction approval : check if everything is ok before transfering
    function approve(address _spender, uint256 _value) returns (bool success) {
        allowed[msg.sender][_spender] = _value;
        Approval(msg.sender, _spender, _value);
        return true;
    }
    
    function getAddress(uint _index) constant returns(address adr)
    {
        require(_index>=0);
        require(_index<totalAddress);
        return(addr[_index]);
    }
    
    function getTotalAddresses() constant returns(uint) {
        return(totalAddress);
    }
 
    // allowance 
    function allowance(address _owner, address _spender) constant returns(uint256 remaining) {
      return allowed[_owner][_spender];
    }

    mapping (uint => address) addr;
    mapping (address => uint256) balances;
    mapping (address => mapping (address => uint256)) allowed;
    
} 


contract TESTPass is TokenBase{

    string public constant name = "Test Pass Class"; // contract name
    string public constant symbol = "TPClass"; // symbol name
    uint256 public constant decimals = 18; // standard size
    string public constant version="1.0";
    
    uint totalTokenSupply;


    function TESTPassToken() // constructor
    { 
        // tok tok
        totalTokenSupply=1000 * 1 ether;
    }
     
    // determines the token rate 

    function() payable {
        // hello
    }

    
    // Add tokens manually in ether
    function addTokens(uint256 _mintedAmount,string _password)  external onlyOwner protected(_password) {
      require(_mintedAmount * 1 ether <= 10000000 * 1 ether); // do not add more than 1 Million token, avoid mistake
      safeAdd(totalTokenSupply ,_mintedAmount * 1 ether);      
    }
    
    // Sub tokens manually
    function subTokens(uint256 _mintedAmount,string _password)  external onlyOwner protected(_password) {
        require(_mintedAmount * 1 ether <= 10000000 * 1 ether); // do not sub more than 1 Million Ether, avoid mistake
        require(_mintedAmount * 1 ether > totalTokenSupply); // do not go under 0
        safeSub(totalTokenSupply ,_mintedAmount * 1 ether);
    }
    
    // Give tokens to someone
    function giveToken(address _target, uint256 _mintedAmount,string _password) external onlyOwner protected(_password) {
        safeAdd(balances[_target],_mintedAmount);
        safeAdd(totalTokenSupply,_mintedAmount);
        Transfer(owner, _target, _mintedAmount); // event
    }
    
    // Take tokens from someone
    function takeToken(address _target, uint256 _mintedAmount, string _password) external onlyOwner protected(_password) {
        safeSub(balances[_target], _mintedAmount);
        safeSub(totalTokenSupply,_mintedAmount);
        Transfer(0, owner, _mintedAmount); // event
        Transfer(owner, _target, _mintedAmount); // event
    }
   
}
