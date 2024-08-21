// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;


interface IERC20 {
    function transfer(address recipient, uint256 amount) external returns (bool);
    function balanceOf(address account) external view returns (uint256);
}

contract PeerReviewIncentive {
    IERC20 public rewardToken;
    address public instructor;  // The person who manages the reward distribution
    uint256 public rewardAmount;  // Amount of tokens rewarded for each review

    struct Review {
        address reviewer;
        string assignmentHash;
        bool rewarded;
    }

    mapping(address => Review[]) public reviews;

    modifier onlyInstructor() {
        require(msg.sender == instructor, "Only the instructor can perform this action");
        _;
    }

    constructor(IERC20 _rewardToken, uint256 _rewardAmount) {
        instructor = msg.sender;
        rewardToken = _rewardToken;
        rewardAmount = _rewardAmount;
    }

    function submitReview(address _student, string memory _assignmentHash) public {
        // For storing the review details
        reviews[_student].push(Review({
            reviewer: msg.sender,
            assignmentHash: _assignmentHash,
            rewarded: false
        }));
    }

    function rewardReview(address _student, uint256 _reviewIndex) public onlyInstructor {
        require(_reviewIndex < reviews[_student].length, "Invalid review index");
        Review storage review = reviews[_student][_reviewIndex];
        require(!review.rewarded, "This review has already been rewarded");

        // For transfering tokens to the reviewer
        require(rewardToken.transfer(review.reviewer, rewardAmount), "Token transfer failed");

        // Marking the review as rewarded
        review.rewarded = true;
    }

    function getReviews(address _student) public view returns (Review[] memory) {
        return reviews[_student];
    }
}
