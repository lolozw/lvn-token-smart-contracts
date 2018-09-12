pragma solidity 0.4.24;

import "./ERC20.sol";


/**
 * @title ERC223Basic additions to ERC20Basic
 * @dev see also: https://github.com/ethereum/EIPs/issues/223               
 *
*/
contract ERC223 is ERC20 {

    event Transfer(address indexed _from, address indexed _to, uint256 _value, bytes indexed _data);

    function transfer(address _to, uint256 _value, bytes _data) public returns (bool success);
    function contractFallback(address _to, uint _value, bytes _data) internal returns (bool success);
    function isContract(address _addr) internal view returns (bool);
}
