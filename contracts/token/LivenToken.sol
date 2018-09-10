pragma solidity 0.4.24;

import "./Basic223Token.sol";
import "./Ownable.sol";


contract LivenToken is Basic223Token, Ownable {

    string private name_ = 'LivenToken';
    string private symbol_ = 'LVN';
    uint256 private decimals_ = 18;
    uint256 public initialAmount = 1000000000 * (10 ** decimals_);

    bool private mintingFinished_ = false;

    event Mint(address indexed to, uint256 amount);
    event MintFinished();

    modifier canMint() {
        require(!mintingFinished_);
        _;
    }

    modifier hasMintPermission() {
        require(msg.sender == owner());
        _;
    }

    function mintingFinished() public view returns(bool) {
        return mintingFinished_;
    }

    constructor() public {
        _mint(msg.sender, initialAmount);
    }

    function() public payable { revert(); }
    
    function burn(address _account, uint256 _amount) public {
        _burn(_account, _amount);
    }

    function burnFrom(address _account, uint256 _amount) public {
        _burnFrom(_account, _amount);
    }

    function name() public view returns(string) {
        return name_;
    }

    function symbol() public view returns(string) {
        return symbol_;
    }

    function decimals() public view returns(uint256) {
        return decimals_;
    }

    function mint(address _to, uint256 _amount) public hasMintPermission canMint returns (bool) {
        _mint(_to, _amount);
        emit Mint(_to, _amount);
        return true;
    }

    function finishMinting() public onlyOwner canMint returns (bool) {
        mintingFinished_ = true;
        emit MintFinished();
        return true;
    }

    function safeTransfer(address _to, uint256 _value) public {
        require(transfer(_to, _value));
    }

    function safeTransferFrom(address _from, address _to, uint256 _value) public {
        require(transferFrom(_from, _to, _value));
    }

    function safeApprove( address _spender, uint256 _currentValue, uint256 _value ) public {
        require(allowance(msg.sender, _spender) == _currentValue);
        require(approve(_spender, _value));
    }
}
