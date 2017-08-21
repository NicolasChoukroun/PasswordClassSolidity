# PasswordClassSolidity
This is a simple password class to add an additional level of security to your solidity smart contracts

How to use it?

1) add the pass class to your contract
2) be sure that your token Inherited from pass
3) send the password when you deploy the contract, it will be hashed and saved.
 function TESTPassToken(string _password) // constructor
4) when you want to protect a function, add the password part in the function definition as follow:
     function subTokens(uint256 _mintedAmount,string _password)  external onlyOwner protected(_password) {
