pragma solidity ^0.4.23;

contract Casino {
    address public owner;

    constructor() public {
        owner = msg.sender;
    }

    function kill() public {
        if(msg.sender == owner) selfdestruct(owner);
    }
}