// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

contract OpenRepoEarnings {
    address public owner;

    struct Contributor {
        address contributorAddress;
        uint256 contributions;
        uint256 earnings;
    }
 
    mapping(address => Contributor) public contributors;
    address[] public contributorAddresses;
    uint256 public totalContributions;
    uint256 public rewardPool;

    event ContributionLogged(address indexed contributor, uint256 contributions);
    event RewardDistributed(address indexed contributor, uint256 earnings);
    event FundsAddedToPool(address indexed sender, uint256 amount);

    modifier onlyOwner() {
        require(msg.sender == owner, "Only the owner can perform this action");
        _;
    }  

    constructor() {
        owner = msg.sender;
    }

    function logContribution(address _contributor, uint256 _amount) external onlyOwner {
        Contributor storage contributor = contributors[_contributor];

        if (contributor.contributorAddress == address(0)) {
            contributor.contributorAddress = _contributor;
            contributorAddresses.push(_contributor);
        }

        contributor.contributions += _amount;
        totalContributions += _amount;

        emit ContributionLogged(_contributor, _amount);
    }

    function addFundsToRewardPool() external payable {
        require(msg.value > 0, "Funds must be greater than zero");
        rewardPool += msg.value;

        emit FundsAddedToPool(msg.sender, msg.value);
    }

    function distributeRewards() external onlyOwner {
        require(totalContributions > 0, "No contributions logged");
        require(rewardPool > 0, "Reward pool is empty");

        for (uint256 i = 0; i < contributorAddresses.length; i++) {
            address contributorAddress = contributorAddresses[i];
            Contributor storage contributor = contributors[contributorAddress];
            if (contributor.contributions > 0) {
                uint256 reward = (contributor.contributions * rewardPool) / totalContributions;
                contributor.earnings += reward;
                rewardPool -= reward;

                payable(contributor.contributorAddress).transfer(reward);
                emit RewardDistributed(contributor.contributorAddress, reward);
            }
        }

        totalContributions = 0; // Reset contributions after distribution
    }
}
