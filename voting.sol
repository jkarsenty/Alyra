// Voting.sol
// SPDX-License-Identifier: MIT
pragma solidity 0.6.11;
import "https://github.com/OpenZeppelin/openzeppelin-contracts/contracts/access/Ownable.sol";

contract Voting is Ownable{
    /*
    TO DO
    - Assert each voter vote once ! a mapping ?!
    - Understand the event change workflow
    - Put some assert for the count before and after vote etc...
    */
    struct Voter {
        bool isRegistered;
        bool hasVoted;
        uint votedProposalId;
    }
    struct Proposal {
        string description;
        uint voteCount;
    }
    enum WorkflowStatus {
        RegisteringVoters,
        ProposalsRegistrationStarted,
        ProposalsRegistrationEnded,
        VotingSessionStarted,
        VotingSessionEnded,
        VotesTallied
    }
    
    event VoterRegistered(address voterAddress);
    event ProposalsRegistrationStarted();
    event ProposalsRegistrationEnded();
    event ProposalRegistered(uint proposalId);
    event VotingSessionStarted();
    event VotingSessionEnded();
    event Voted (address voter, uint proposalId);
    event VotesTallied();
    event WorkflowStatusChange(WorkflowStatus previousStatus, WorkflowStatus newStatus);
    
    uint256 proposalId = 0;
    uint256 winningProposalId;
    
    // Declare workflow variable of type WorkflowStatus (which is enum)
    WorkflowStatus public workflow = WorkflowStatus.RegisteringVoters; //default = RegisteringVoters
    
    // Mapping
    mapping(address => Voter) whitelist; //map a voter to his address
    mapping(uint256 => Proposal) proposals; //map a proposal to his id
    
    // 1) Owner register the whitelist
    function registerVoter(address _address) public onlyOwner{
        require(!whitelist[_address].isRegistered,"this voter is already registered");
        Voter memory newVoter;
        newVoter.isRegistered = true;
        whitelist[_address] = newVoter;
        emit VoterRegistered(_address);
    }
    
    // 2) Owner makes register session begin
    function startProposalsRegistration() public onlyOwner {
        require(workflow == WorkflowStatus.RegisteringVoters,"Must be in the RegisteringVoters to start ProposalsRegistration");
        workflow = WorkflowStatus.ProposalsRegistrationStarted;
        emit ProposalsRegistrationStarted();
        emit WorkflowStatusChange(WorkflowStatus.RegisteringVoters,WorkflowStatus.ProposalsRegistrationStarted);
    }
    // 3) Whitelisted voters can register proposals
    function saveProposal(string memory _description) public {
        require(workflow == WorkflowStatus.ProposalsRegistrationStarted,"Saving a proposal must be during the Registration workflow");
        require(whitelist[msg.sender].isRegistered,"A voter must be registered to save a proposal");
        Proposal memory newProposal;
        newProposal.description = _description;
        proposals[proposalId] = newProposal;
        emit ProposalRegistered(proposalId);
        proposalId++;
    }
    
    // 4) Owner makes register session end
    function endProposalsRegistration() public onlyOwner{
        require(workflow == WorkflowStatus.ProposalsRegistrationStarted,"ProposalsRegistration must have been started to end it");
        workflow = WorkflowStatus.ProposalsRegistrationEnded;
        emit ProposalsRegistrationEnded();
        emit WorkflowStatusChange(WorkflowStatus.ProposalsRegistrationStarted,WorkflowStatus.ProposalsRegistrationEnded);
    }
    // 5) Owner makes voting session begin
    function startVotingSession() public onlyOwner {
        require(workflow == WorkflowStatus.ProposalsRegistrationEnded,"ProposalsRegistration must end before to start the VotingSession");
        workflow = WorkflowStatus.VotingSessionStarted;
        emit VotingSessionStarted();
        emit WorkflowStatusChange(WorkflowStatus.ProposalsRegistrationEnded,WorkflowStatus.VotingSessionStarted);
        
    }
    // 6) Whitelisted voters can vote for proposals
    function voteForProposal(uint256 _proposalId) public {
        require(workflow == WorkflowStatus.VotingSessionStarted,"Voting for proposal must be during the Voting session");
        require(whitelist[msg.sender].isRegistered,"A voter must be registered to save a proposal");
        require(_proposalId <= proposalId,"your choice of proposal is too high, there are less proposals");
        whitelist[msg.sender].hasVoted = true;
        whitelist[msg.sender].votedProposalId = _proposalId;
        proposals[_proposalId].voteCount++;
        emit Voted(msg.sender,_proposalId);
    }
    
    // 7) Owner makes voting session end
    function endVotingSession() public onlyOwner {
        require(workflow == WorkflowStatus.VotingSessionStarted,"VotingSession must have been started to end it");
        workflow = WorkflowStatus.VotingSessionEnded;
        emit VotingSessionEnded();
        emit WorkflowStatusChange(WorkflowStatus.VotingSessionStarted,WorkflowStatus.VotingSessionEnded);
    }
    // 8) Owner count the votes
    function tallyVotes() public onlyOwner {
        require(workflow == WorkflowStatus.VotingSessionEnded,"VotingSession must have ended before VotesTallied");
        workflow = WorkflowStatus.VotesTallied;
        emit VotesTallied();
        emit WorkflowStatusChange(WorkflowStatus.VotingSessionEnded,WorkflowStatus.VotesTallied);
        // tally the vote
        winningProposalId = 0; // init winningProposalId
        for (uint256 i = 0; i < proposalId; i++){
            if (proposals[i].voteCount > proposals[winningProposalId].voteCount){
                winningProposalId = i;
            }
        }
    }
    
    // 9) Everyone can see the restults
    function getWinningProposal() public view returns(uint256){
        return winningProposalId;
    }
    
      // non mandatory for Defi but useful for my test
    function getNumOfProposals() public view onlyOwner returns(uint256){
        return proposalId;
    }
}
