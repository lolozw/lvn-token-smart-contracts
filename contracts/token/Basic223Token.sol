pragma solidity ^0.4.18;

import './ERC223Basic.sol';
import './Liven223Receiver.sol';
import './ERC20.sol';

contract Basic223Token is ERC223Basic, ERC20 {
  
    event Something(string);
    event SomethingAddress(address);

    /**
    * @dev transfer token for a specified address
    * @param _to The address to transfer to.
    * @param _value The amount to be transferred
    * @param _data is arbitrary data sent with the token transferFrom. Simulates ether tx.data
    * @return bool successful or not
    */
    function transfer(address _to, uint _value, bytes _data) public returns (bool success) {
        require(_to != address(0));
        require(_value <= balanceOf(msg.sender));
        require(balanceOf(_to).add(_value) > balanceOf(_to));  // Detect balance overflow
    
        emit Something("Basic223Token.transfer(addr, uint, bytes)");
        emit SomethingAddress(msg.sender);
        assert(transfer(_to, _value));               //@dev Save transfer
        emit Something("After transfer(addr, uint)");

        if (isContract(_to)){
          emit Something("Basic223Token.transfer called by contract");
          return contractFallback(_to, _value, _data);
        }
        return true;
    }

    //function that is called when transaction target is a contract
    function contractFallback(address _to, uint _value, bytes _data) internal returns (bool success) {
        emit Something("Before Receiver.tokenFallback");
        Liven223Receiver reciever = Liven223Receiver(_to);
        return reciever.tokenFallback(msg.sender, _value, _data);
    }

    //assemble the given address bytecode. If bytecode exists then the _addr is a contract.
    function isContract(address _addr) internal returns (bool is_contract) {
        // retrieve the size of the code on target address, this needs assembly
        uint length;
        assembly { length := extcodesize(_addr) }
        return length > 0;
    }
}
