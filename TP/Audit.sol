pragma solidity ^0.5.12;

contract Crowdsale {
    using SafeMath for uint256;

    address public owner; // the owner of the contract
    address public escrow; // wallet to collect raised ETH

    // AUDIT : No need to initiate the variable with "= 0"
    uint256 public savedBalance;
    mapping(address => uint256) public balances; // Balances in incoming Ether

    // Initialization
    function Crowdsale(address _escrow) public {
        owner = tx.origin; // AUDIT : Must not use tx.origin
        // add address of the specific contract
        escrow = _escrow;
    }

    // function to receive ETH
    function() public {
        // AUDIT : Miss some require
        balances[msg.sender] = balances[msg.sender].add(msg.value);
        savedBalance = savedBalance.add(msg.value);
        escrow.send(msg.value);
    }

    // refund investisor
    function withdrawPayments() public {
        address payee = msg.sender;
        uint256 payment = balances[payee];

        payee.send(payment);

        savedBalance = savedBalance.sub(payment);
        balances[payee] = 0;
    }
}
