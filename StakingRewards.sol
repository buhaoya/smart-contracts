// SPDX-License-Identifier: GPL-3.0
pragma solidity ^0.8.19;

import "./zERC20.sol";

contract StakingRewards{
    zERC20 public rewardsToken;
    zERC20 public stakingToken;
    uint256 public periodFinish = 60000000;
    uint256 public rewardRate = 10;
    uint public lastUpdateBlockNumber;
    uint256 public rewardPerTokenStored;

    mapping(address => uint256) public userRewardPerTokenPaid;
    mapping(address => uint256) public rewards;

    uint256 private _totalSupply;
    mapping(address => uint256) private _balances;

    constructor(
        address _rewardsToken,
        address _stakingToken
    ) public {
        rewardsToken = zERC20(_rewardsToken);
        stakingToken = zERC20(_stakingToken);
    }

    function balanceOf(address account) external view returns (uint256) {
        return _balances[account];
    }

    function lastTimeRewardApplicable() public view returns (uint) {
        return block.number < periodFinish ? block.number : periodFinish;
    }

    function rewardPerToken() public view returns (uint256) {
        if (_totalSupply == 0) {
            return rewardPerTokenStored;
        }
        uint blockChange = lastTimeRewardApplicable() - lastUpdateBlockNumber;
        uint256 rewardChange = blockChange * rewardRate * 1e18;
        return rewardPerTokenStored + rewardChange/_totalSupply;
    }

    function earned(address account) public view returns (uint256) {
        uint256 rewardChange = rewardPerToken() - userRewardPerTokenPaid[account];
        return _balances[account] * rewardChange / 1e18 + rewards[account];
    }

    function stake(uint256 amount) public updateReward(msg.sender){
        require(amount > 0, "Cannot stake 0");
        _totalSupply = _totalSupply + amount;
        _balances[msg.sender] = _balances[msg.sender] + amount;
        stakingToken.transferFrom(msg.sender, address(this), amount);
        emit Staked(msg.sender, amount);
    }

    function withdraw(uint256 amount) public updateReward(msg.sender) {
        require(amount > 0, "Cannot withdraw 0");
        _totalSupply = _totalSupply- amount;
        _balances[msg.sender] = _balances[msg.sender]- amount;
        stakingToken.transfer(msg.sender, amount);
        emit Withdrawn(msg.sender, amount);
    }

    function getReward() public updateReward(msg.sender) {
        uint256 reward = rewards[msg.sender];
        if (reward > 0) {
            rewards[msg.sender] = 0;
            rewardsToken.transfer(msg.sender, reward);
            emit RewardPaid(msg.sender, reward);
        }
    }

    modifier updateReward(address account){
        rewardPerTokenStored = rewardPerToken();
        lastUpdateBlockNumber = lastTimeRewardApplicable();
        if (account != address(0)) {
            rewards[account] = earned(account);
            userRewardPerTokenPaid[account] = rewardPerTokenStored;
        }
        _;
    }

    event Staked(address indexed user, uint256 amount);
    event Withdrawn(address indexed user, uint256 amount);
    event RewardPaid(address indexed user, uint256 reward);
}