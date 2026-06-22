// SPDX-License-Identifier: MIT
pragma solidity 0.8.34;

contract BaseGovernanceDAO {
    string public name = "Base Alpha Governance";
    address public admin;

    struct Proposal {
        uint256 id;
        string description;
        uint256 votesFor;
        uint256 votesAgainst;
        uint256 endTime;
        bool executed;
        mapping(address => bool) hasVoted;
    }

    uint256 public proposalCount;
    mapping(uint256 => Proposal) public proposals;

    event ProposalCreated(uint256 indexed id, string description, uint256 endTime);
    event VoteCast(address indexed voter, uint256 indexed proposalId, bool support);
    event ProposalExecuted(uint256 indexed id);

    modifier onlyAdmin() {
        require(msg.sender == admin, "Only admin can call this");
        _;
    }

    constructor() {
        admin = msg.sender;
    }

    // ۱. تابع ساخت پروپوزال جدید روی شبکه بیس
    function createProposal(string memory _description, uint256 _durationInMinutes) public onlyAdmin {
        proposalCount++;
        
        Proposal storage newProposal = proposals[proposalCount];
        newProposal.id = proposalCount;
        newProposal.description = _description;
        newProposal.endTime = block.timestamp + (_durationInMinutes * 1 minutes);
        newProposal.executed = false;

        emit ProposalCreated(proposalCount, _description, newProposal.endTime);
    }

    // ۲. تابع اصلی ثبت رای
    function castVote(uint256 _proposalId, bool _support) public {
        Proposal storage proposal = proposals[_proposalId];
        require(block.timestamp < proposal.endTime, "Voting has ended");
        require(!proposal.hasVoted[msg.sender], "You have already voted");

        proposal.hasVoted[msg.sender] = true;

        if (_support) {
            proposal.votesFor++;
        } else {
            proposal.votesAgainst++;
        }

        emit VoteCast(msg.sender, _proposalId, _support);
    }

    // ۳. تابع اتمام و اجرای پروپوزال
    function executeProposal(uint256 _proposalId) public onlyAdmin {
        Proposal storage proposal = proposals[_proposalId];
        require(block.timestamp >= proposal.endTime, "Voting is still active");
        require(!proposal.executed, "Proposal already executed");

        proposal.executed = true;

        emit ProposalExecuted(_proposalId);
    }

    // تغییر مدیریت کانترکت برای تنوع تراکنش‌ها
    function transferOwnership(address _newAdmin) public onlyAdmin {
        require(_newAdmin != address(0), "Invalid address");
        admin = _newAdmin;
    }
}