//PullPayment.sol
pragma solidity 0.6.11;

contract PullPayment {
    mapping(address => uint256) credits;

    // Allow for the pull of an amount to an address
    function allowForPull(address receiver, uint256 amount) private {
        credits[receiver] += amount;
    }

    // Actual withdraw of the allowed pull request
    function withdrawCredits() public {
        uint256 amount = credits[msg.sender];

        require(amount != 0);
        require(address(this).balance >= amount);

        credits[msg.sender] = 0;
        msg.sender.transfer(amount);
    }
}
