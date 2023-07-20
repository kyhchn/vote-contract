// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract Vote {
    struct Voter {
        bool isRegistered;
        bool hasVoted;
        uint256 votedCandidateId;
    }

    struct Candidate {
        string name;
        uint256 voteCount;
    }

    address public admin;
    bool public votingStarted; // Menandakan apakah pemilihan telah dimulai
    bool public votingEnded; // Menandakan apakah pemilihan telah berakhir

    mapping(address => Voter) public voters;
    Candidate[] public candidates;

    event VotingStarted(uint256 indexed startDate, uint256 indexed endDate);
    event CandidateRegistered(uint256 indexed candidateId, string name);
    event VoteCasted(address indexed voter, uint256 indexed candidateId);
    event VotingEnded(uint256 indexed endDate);
    event ResultAnnounced(
        uint256 indexed winnerId,
        string name,
        uint256 voteCount
    );

    modifier onlyAdmin() {
        require(msg.sender == admin, "Only admin can perform this action");
        _;
    }

    modifier votingInProgress() {
        require(votingStarted && !votingEnded, "Voting is not in progress");
        _;
    }

    constructor() {
        admin = msg.sender;
    }

    function startVoting() public onlyAdmin {
        require(!votingStarted, "Voting has already started");
        require(candidates.length > 0, "No candidates registered");

        votingStarted = true;
        votingEnded = false;

        emit VotingStarted(block.timestamp, block.timestamp + 7 days);
    }

    function registerCandidate(string memory _name) public onlyAdmin {
        require(!votingStarted, "Voting has already started");

        uint256 candidateId = candidates.length;
        for (uint256 i = 0; i < candidates.length; i++) {
            require(
                keccak256(bytes(candidates[i].name)) != keccak256(bytes(_name)),
                "Candidate already registered"
            );
        }
        candidates.push(Candidate(_name, 0));
        emit CandidateRegistered(candidateId, _name);
    }

    function registerVoter(address _voter) public onlyAdmin {
        require(!voters[_voter].isRegistered, "Voter already registered");
        voters[_voter].isRegistered = true;
    }

    function castVote(uint256 _candidateId) public votingInProgress {
        Voter storage sender = voters[msg.sender];
        require(sender.isRegistered, "Voter is not registered");
        require(!sender.hasVoted, "Voter has already voted");
        require(_candidateId < candidates.length, "Invalid candidate ID");

        sender.hasVoted = true;
        sender.votedCandidateId = _candidateId;
        candidates[_candidateId].voteCount++;
        emit VoteCasted(msg.sender, _candidateId);
    }

    function endVoting() public onlyAdmin votingInProgress {
        votingEnded = true;
        emit VotingEnded(block.timestamp);
    }

    function announceResult() public onlyAdmin {
        require(votingEnded, "Voting has not ended yet");

        uint256 winnerId = 0;
        uint256 maxVotes = 0;
        for (uint256 i = 0; i < candidates.length; i++) {
            if (candidates[i].voteCount > maxVotes) {
                winnerId = i;
                maxVotes = candidates[i].voteCount;
            }
        }

        emit ResultAnnounced(winnerId, candidates[winnerId].name, maxVotes);
    }

    function getCandidates() public view returns (Candidate[] memory) {
        return candidates;
    }
}
