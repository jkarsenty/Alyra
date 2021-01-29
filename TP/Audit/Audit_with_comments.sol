// AUDIT : do not use the ^ but use directly a version of solidity
pragma solidity ^0.5.12;

// AUDIT : Miss the import
// import "https://github.com/OpenZeppelin/openzeppelin-contracts/blob/master/contracts/math/SafeMath.sol";

contract Crowdsale {
    using SafeMath for uint256;

    // AUDIT : créer des evenements car il n'y en a aucun
    // AUDIT : Add some require

    // AUDIT : better to use the audited librairy of Zeppelin with is Ownable
    address public owner; // the owner of the contract

    // AUDIT : escrow must be payable and not public
    address public escrow; // wallet to collect raised ETH

    // AUDIT : No need to initiate the variable with "= 0"
    uint256 public savedBalance = 0; // Total amount raised in ETH

    mapping(address => uint256) public balances; // Balances in incoming Ether

    /* AUDIT : probleme name of function is name of contract
    if it's initialization must be constructor ? */
    // Initialization
    function Crowdsale(address _escrow) public {
        // AUDIT : Must not use tx.origin (voir §tx.origin)
        owner = tx.origin;

        // add address of the specific contract
        escrow = _escrow;
    }

    // AUDIT : probleme name of function missing
    // AUDIT : need to be external and payable if it's for receive ETH
    // function to receive ETH
    function() public {
        balances[msg.sender] = balances[msg.sender].add(msg.value);
        savedBalance = savedBalance.add(msg.value);

        // AUDIT : do not use .send but use transfer instead or use .call{value: amount}("") (voir §3)
        // AUDIT : besoin de gerer l'exception si l'envoi echoue (voir §4 )
        escrow.send(msg.value);
    }

    // refund investisor
    function withdrawPayments() public {
        address payee = msg.sender;
        uint256 payment = balances[payee];

        // AUDIT : do not use .send but use transfer instead or use .call{value: amount}("") (voir §3)
        // AUDIT : besoin de gerer l'exception si l'envoi echoue (voir §4 )
        payee.send(payment);

        // AUDIT : do not change a state after a .call() or contract.method()
        savedBalance = savedBalance.sub(payment);
        balances[payee] = 0;
    }
}
