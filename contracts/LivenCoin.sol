pragma solidity 0.4.24;

import "./lib/ERC223.sol";
import "./lib/Ownable.sol";
import "./lib/SafeMath.sol";
import "./lib/Generic223Receiver.sol";

contract LivenCoin is ERC223, Ownable {

    using SafeMath for uint256;

    string private name_ = "LivenCoin";
    string private symbol_ = "LVN";
    uint256 private decimals_ = 18;
    uint256 public initialAmount = 10000000000 * (10 ** decimals_);

    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);
    
    mapping (address => uint256) internal balances_;
    mapping (address => mapping (address => uint256)) private allowed_;

    uint256 internal totalSupply_;
    bool public unlocked = false;

    modifier afterUnlock() {
        require(unlocked || msg.sender == owner(), "Only owner can call this function before unlock.");
        _;
    }

    constructor() public {
        totalSupply_ = totalSupply_.add(initialAmount);
        balances_[msg.sender] = balances_[msg.sender].add(initialAmount);
        emit Transfer(address(0), msg.sender, initialAmount);
    }

    function() public payable { revert("Cannot send ETH to this address."); }
    
    function name() public view returns(string) {
        return name_;
    }

    function symbol() public view returns(string) {
        return symbol_;
    }

    function decimals() public view returns(uint256) {
        return decimals_;
    }

    function safeTransfer(address _to, uint256 _value) public afterUnlock {
        require(transfer(_to, _value), "Transfer failed.");
    }

    function safeTransferFrom(address _from, address _to, uint256 _value) public afterUnlock {
        require(transferFrom(_from, _to, _value), "Transfer failed.");
    }

    function safeApprove( address _spender, uint256 _currentValue, uint256 _value ) public afterUnlock {
        require(allowed_[msg.sender][_spender] == _currentValue, "Current allowance value does not match.");
        approve(_spender, _value);
    }

    // ERC20
    function totalSupply() public view returns (uint256) {
        return totalSupply_;
    }

    function balanceOf(address _owner) public view returns (uint256) {
        return balances_[_owner];
    }

    function unlock() public onlyOwner {
        unlocked = true;
    }

    function allowance(address _owner, address _spender) public view returns (uint256) {
        return allowed_[_owner][_spender];
    }

    function transfer(address _to, uint256 _value) public afterUnlock returns (bool) {
        require(_value <= balances_[msg.sender], "Value exceeds balance of msg.sender.");
        require(_to != address(0), "Cannot send tokens to zero address.");

        balances_[msg.sender] = balances_[msg.sender].sub(_value);
        balances_[_to] = balances_[_to].add(_value);
        emit Transfer(msg.sender, _to, _value);
        return true;
    }

    function approve(address _spender, uint256 _value) public afterUnlock returns (bool) {
        allowed_[msg.sender][_spender] = _value;
        emit Approval(msg.sender, _spender, _value);
        return true;
    }

    function transferFrom(address _from, address _to, uint256 _value) public afterUnlock returns (bool) {
        require(_value <= balances_[_from], "Value exceeds balance of msg.sender.");
        require(_value <= allowed_[_from][msg.sender], "Value exceeds allowance of msg.sender for this owner.");
        require(_to != address(0), "Cannot send tokens to zero address.");

        balances_[_from] = balances_[_from].sub(_value);
        balances_[_to] = balances_[_to].add(_value);
        allowed_[_from][msg.sender] = allowed_[_from][msg.sender].sub(_value);
        emit Transfer(_from, _to, _value);
        return true;
    }

    function increaseApproval(address _spender, uint256 _addedValue) public afterUnlock returns (bool) {
        allowed_[msg.sender][_spender] = allowed_[msg.sender][_spender].add(_addedValue);
        emit Approval(msg.sender, _spender, allowed_[msg.sender][_spender]);
        return true;
    }

    function decreaseApproval(address _spender, uint256 _subtractedValue) public afterUnlock returns (bool) {
        uint256 oldValue = allowed_[msg.sender][_spender];
        if (_subtractedValue >= oldValue) {
            allowed_[msg.sender][_spender] = 0;
        } else {
            allowed_[msg.sender][_spender] = oldValue.sub(_subtractedValue);
        }
        emit Approval(msg.sender, _spender, allowed_[msg.sender][_spender]);
        return true;
    }

    // ERC223
    function transfer(address _to, uint _value, bytes _data) public afterUnlock returns (bool success) {
        require(_to != address(0), "Cannot transfer token to zero address.");
        require(_value <= balanceOf(msg.sender), "Value exceeds balance of msg.sender.");
        
        transfer(_to, _value);

        if (isContract(_to)) {
            return contractFallback(_to, _value, _data);
        }
        return true;
    }

    function contractFallback(address _to, uint _value, bytes _data) internal returns (bool success) {
        Generic223Receiver receiver = Generic223Receiver(_to);
        return receiver.tokenFallback(msg.sender, _value, _data);
    }

    // Assemble the given address bytecode. If bytecode exists then the _addr is a contract.
    function isContract(address _addr) internal view returns (bool) {
        // retrieve the size of the code on target address, this needs assembly
        uint length;
        assembly { length := extcodesize(_addr) }
        return length > 0;
    }
}
