pragma solidity ^0.4.23;

contract Casino {
    address public owner;
    uint256 public minimumBet;
    uint256 public totalBet;
    uint256 public numberOfBets;
    uint256 public maxAmountOfBets = 100;
    address[] public players;

    struct Player {
        uint256 amountBet;
        uint256 numberSelected;
    }

    // The address of the player and => the user info
    mapping(address => Player) public playerInfo;

    // Fallback function in case someone sends ther to the contract so it doesn't get lost 
    // and to increase the treasury of this contract that ill be distributed in each game
    function() public payable{} // * Research this more *

    constructor(uint256 _minimumBet) public {
        owner = msg.sender;
        if(_minimumBet != 0) minimumBet = _minimumBet;
    }

    function kill() public {
        if(msg.sender == owner) selfdestruct(owner);
    }

    // Check if a player has already bet (not allwed to bet twice)
    // Iterates through mapping of player addresses to check if any match
    // "View" means this function does not cost any ETH since its 
        // relaying info already on the blockchain
    function checkPlayerExists(address player) public view returns(bool) {
        for(uint256 i = 0; i < players.length; i++){
            if(players[i] == player) return true;
        }
        return false;
    }

    // To bet between 1 and 10 inclusive
    function bet(uint256 numberSelected) public payable {

        // "payable" modifier means this contract can accept ETH
        // If any of the condiditons return false, ETH is sent back to player
        // msg.sender: address of user
        // msg.value: amount of ether paid when executing "payable" function

        require(!checkPlayerExists(msg.sender)); // Check if player has bet already
        require(numberSelected >= 1 && numberSelected <= 10); // Check number is valid
        require(msg.value >= minimumBet); // Check bet is above minimum

        playerInfo[msg.sender].amountBet = msg.value;
        playerInfo[msg.sender].numberSelected = numberSelected;
        numberOfBets++;
        players.push(msg.sender);
        totalBet += msg.value;

        if(numberOfBets >= maxAmountOfBets) generateNumberWinner();

    }

    // Generates a number between 1 and 10 that will be the winner 
    function generateNumberWinner() public {
        // Takes last digit of block number and adds 1
        uint256 numberGenerated = block.number % 10 + 1; // "Random" but not secure
        distributePrizes(numberGenerated);
    }

    // Sends the corresponding ether to each winner depending on the total bets
    function distributePrizes(uint256 numberWinner) public {
        address[100] memory winners; // Creates a temporary in-memory array of winners
        uint256 count = 0; // This is the count for the array of winners

        for(uint256 i = 0; i < players.length; i++) {
            address playerAddress = players[i];
            if(playerInfo[playerAddress].numberSelected == numberWinner) {
                winners[count] = playerAddress; // Add a winning address to array of winners
                count++;
            }
            delete playerInfo[playerAddress]; // Deletes player once categorized W/L
        }

        players.length = 0; // Deletes entire players array
        uint256 winnerEtherAmount = totalBet/winners.length; // How much each winner gets
        for (uint256 j = 0; j < count; j++) {
            if(winners[j] != address(0)) { // check that the address in this fixed array is not empty
                winners[j].transfer(winnerEtherAmount);
            } 
        }
    }

}