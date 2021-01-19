// Voting.sol
// SPDX-License-Identifier: MIT
pragma solidity 0.6.11;
import "https://github.com/OpenZeppelin/openzeppelin-contracts/contracts/access/Ownable.sol";

contract Voting is Ownable{
    
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
    uint256 winningProposalId;
    
    event VoterRegistered(address voterAddress);
    event ProposalsRegistrationStarted();
    event ProposalsRegistrationEnded();
    event ProposalRegistered(uint proposalId);
    event VotingSessionStarted();
    event VotingSessionEnded();
    event Voted (address voter, uint proposalId);
    event VotesTallied();
    event WorkflowStatusChange(WorkflowStatus previousStatus, WorkflowStatus newStatus);
    
    
    // Declare workflow variable of type WorkflowStatus (which is enum)
    WorkflowStatus public workflow=WorkflowStatus.RegisteringVoters; //default = RegisteringVoters

    // 1) Owner register the whitelist
    mapping(address=>bool) registered;
    function registerVoter(address _address) public onlyOwner{
        require(!registered[_address], "this voter is already registered");
        registered[_address]=true;
        emit VoterRegistered(_address);
    }
    
    // 2) Owner makes register session begin
    function turnWorkflowProposalsRegistrationStarted() public onlyOwner {
        require(workflow==WorkflowStatus.RegisteringVoters,"we need to be in the RegisteringVoters to start ProposalsRegistration");
        workflow = WorkflowStatus.ProposalsRegistrationStarted;
        emit ProposalsRegistrationStarted();
        emit WorkflowStatusChange(WorkflowStatus.RegisteringVoters,WorkflowStatus.ProposalsRegistrationStarted);
    }
    // 3) Whitelisted voters can register proposals
    
    // 4) Owner makes register session end
    function turnWorkflowProposalsRegistrationEnded() public onlyOwner{
        require(workflow==WorkflowStatus.ProposalsRegistrationStarted,"we need to have started the ProposalsRegistration to end it");
        workflow = WorkflowStatus.ProposalsRegistrationEnded;
        emit ProposalsRegistrationEnded();
        emit WorkflowStatusChange(WorkflowStatus.ProposalsRegistrationStarted,WorkflowStatus.ProposalsRegistrationEnded);
    }
    // 5) Owner makes voting session begin
    function turnWorkflowVotingSessionStarted() public onlyOwner {
        require(workflow==WorkflowStatus.ProposalsRegistrationEnded,"we need to have ended the ProposalsRegistration to start the VotingSession");
        workflow = WorkflowStatus.VotingSessionStarted;
        emit VotingSessionStarted();
        emit WorkflowStatusChange(WorkflowStatus.ProposalsRegistrationEnded,WorkflowStatus.VotingSessionStarted);
        
    }
    // 6) Whitelisted voters can vote for proposals
    
    // 7) Owner makes voting session end
    function turnWorkflowVotingSessionEnded() public onlyOwner {
        require(workflow==WorkflowStatus.VotingSessionStarted,"we need to have started the VotingSession to end it");
        workflow = WorkflowStatus.VotingSessionEnded;
        emit VotingSessionEnded();
        emit WorkflowStatusChange(WorkflowStatus.VotingSessionStarted,WorkflowStatus.VotingSessionEnded);
    }
    // 8) Owner count the votes
    function turnWorkflowVotesTallied() public onlyOwner {
        require(workflow==WorkflowStatus.VotingSessionEnded,"we need to have ended the VotingSession to do the VotesTallied");
        workflow = WorkflowStatus.VotesTallied;
        emit VotesTallied();
        emit WorkflowStatusChange(WorkflowStatus.VotingSessionEnded,WorkflowStatus.VotesTallied);

    }
    // 9) Everyone can see the restults
    
}
