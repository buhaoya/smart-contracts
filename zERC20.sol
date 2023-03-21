// SPDX-License-Identifier: GPL-3.0
pragma solidity ^0.8.19;

contract zERC20{
    event Transfer(address indexed _from, address indexed _to, uint256 _value);
    event Approval(address indexed _owner, address indexed _spender, uint256 _value);

    string internal _name;
    string internal _symbol;
    uint8 internal _decimals;
    uint256 internal _totalSupply;

    mapping(address => uint256) internal _balances;
    mapping(address => mapping(address => uint256)) internal _allowed;

    constructor (string memory strName,
                string memory strSymbol,
                uint8 iDecimals,
                uint256 iTotalSupply) public 
    {
        _name = strName;
        _symbol = strSymbol;
        _decimals = iDecimals;
        _totalSupply = iTotalSupply;
        _balances[msg.sender] = _totalSupply;
    }

    function name() public view returns (string memory){
        return _name;
    }
    function symbol() public view returns (string memory){
        return _symbol;
    }
    function decimals() public view returns (uint8){
        return _decimals;
    }
    function totalSupply() public view returns (uint256){
        return _totalSupply;
    }
    function balanceOf(address owner) public view returns (uint256 balance){
        return _balances[owner];
    }
    function transfer(address to, uint256 value) public returns (bool success){
        address owner = msg.sender;
        _transfer(owner, to, value);
        return true;
    }

    function _transfer(address from, address to, uint256 value) internal{
        require(from != address(0), "ERC20: transfer from the zero address");
        require(to != address(0), "ERC20: transfer from the zero address");

        _beforeTokenTransfer(from, to, value);

        uint256 fromBalance = _balances[from];
        require(fromBalance >= value, "ERC20: transfer amount exceeds balance");
        _balances[from] -= value;
        _balances[to] += value;

        emit Transfer(from, to, value);

        _afterTokenTransfer(from, to, value);
    }

    function _beforeTokenTransfer(address from, address to, uint256 value) internal{
    }
    function _afterTokenTransfer(address from, address to, uint256 value) internal{
    }

    function transferFrom(address from, address to, uint256 value) public returns (bool success){
        address spender = msg.sender;
        if(from != spender){
            _spendAllowance(from, spender, value);
        }
        _transfer(from, to, value);
        return true;
    }

    function _spendAllowance(address owner, address spender, uint256 value) internal{
        uint256 currentAllowance = allowance(owner, spender);
        if(currentAllowance != type(uint256).max){
            require(currentAllowance >= value, "ERC20: insufficient allowance");
            _approve(owner, spender, currentAllowance-value);
        }
    }

    function approve(address spender, uint256 value) public returns (bool success){
        address owner = msg.sender;
        _approve(owner, spender, value);
        return true;
    }

    function _approve(address owner, address spender, uint256 value) internal {
        require(owner != address(0), "ERC20: approve from the zero address");
        require(spender != address(0), "ERC20: approve to the zero address");
        _allowed[owner][spender] = value;
        emit Approval(owner, spender, value);
    }

    function allowance(address owner, address spender) public view returns (uint256 remaining){
        return _allowed[owner][spender];
    }

}