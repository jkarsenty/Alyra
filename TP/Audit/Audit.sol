pragma solidity 0.6.11;
import "https://github.com/OpenZeppelin/openzeppelin-contracts/blob/master/contracts/math/SafeMath.sol";

contract Crowdsale {
    using SafeMath for uint256;

    // TO DO :
    // - créer des evenements car il n'y en a aucun

    uint256 public savedBalance; // Total amount raised in ETH
    address public owner; // the owner of the contract
    address payable escrow; // wallet to collect raised ETH

    mapping(address => uint256) public balances; // Balances in incoming Ether

    // Initialization
    constructor(address payable _escrow) public {
        require(_escrow != address(0));
        owner = msg.sender;
        // add address of the specific contract
        escrow = _escrow;
    }

    // function to receive ETH
    receive() external payable {
        require(msg.value != 0); // amount received is not null
        balances[msg.sender] = balances[msg.sender].add(msg.value);
        savedBalance = savedBalance.add(msg.value);

        (bool success, ) = escrow.call{value: msg.value}("");
        if (!success) {
            // gerer exception
        }
    }

    // refund investisor
    function withdrawPayments() public {
        require(balances[msg.sender] != 0);
        address payable payee = msg.sender;
        uint256 payment = balances[payee];

        savedBalance = savedBalance.sub(payment);
        balances[payee] = 0;

        (bool success, ) = payee.call{value: payment}("");
        if (!success) {
            // gerer exception
        }
    }
}
