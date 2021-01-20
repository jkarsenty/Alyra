// Bank.sol
// SPDX-License-Identifier: MIT
//pragma solidity 0.6.11;
import "https://github.com/OpenZeppelin/openzeppelin-contracts/contracts/math/SafeMath.sol";

contract Bank {
    using SafeMath for uint256;
    mapping(address => uint256) private _balances;

    function deposit(uint256 _amount) public {
        require(
            msg.sender != address(0),
            "You cannot deposit for the address zero"
        );
        _balances[msg.sender] = _balances[msg.sender].add(_amount);
    }

    function transfer(address _recipient, uint256 _amount) public {
        require(
            _recipient != address(0),
            "You cannot transfer to the address zero"
        );
        require(
            _balances[msg.sender] >= _amount,
            "You have not enough balance"
        );
        _balances[_recipient] = _balances[_recipient].add(_amount);
        _balances[msg.sender] = _balances[msg.sender].sub(_amount);
    }

    function balanceOf(address _address) public view returns (uint256) {
        return _balances[_address];
    }
}
