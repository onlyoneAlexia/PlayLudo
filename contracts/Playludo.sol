// SPDX-License-Identifier: SEE LICENSE IN LICENSE
pragma solidity ^0.8.24;


contract Ludogame{

struct playerdetails{
address playersAddress;
uint256 positions; //this holds the turns/ position of players
bool hasstarted;
}


playerdetails[] public players; // Declare players array
uint256 public currentTurn; // Declare currentTurn variable
uint256 public totalPlayers; // Declare totalPlayers variable
 uint256 public constant WINNING_POSITION = 56; // Winning position on the board

constructor() {
    currentTurn = 0; // Start with the first player
    totalPlayers = 0; // Initialize total players
}
    function joinGame() public {
        require(totalPlayers < 4, "Maximum players reached");
        players.push(playerdetails(msg.sender, 0, false));
        totalPlayers++;
        }

    function rollDice() public returns (uint256) {
        require(msg.sender == players[currentTurn].playersAddress, "Not your turn");

        // Generate a pseudorandom number between 1 and 6
        uint256 randomNumber = (uint256(keccak256(abi.encodePacked(block.timestamp, block.difficulty, currentTurn, msg.sender))) % 6) + 1;

        // Move the player
        movePlayer(randomNumber);
        return randomNumber;
    }

    function movePlayer(uint256 steps) internal {
        playerdetails storage player = players[currentTurn];

        // If the player hasn't started, they need to roll a 6 to start
        if (!player.hasStarted) {
            require(steps == 6, "Need to roll a 6 to start");
            player.hasStarted = true; // Player starts moving
            player.position += 1; // Move to the starting position
        } else {
            player.position += steps; // Move the player
        }

        // Check for winning condition
        if (player.position >= WINNING_POSITION) {
            player.position = WINNING_POSITION; // Set to winning position

        }
        // Move to the next player
        currentTurn = (currentTurn + 1) % totalPlayers;
    }

    function getPlayerPosition(address playerAddress) public view returns (uint256) {
        for (uint256 i = 0; i < players.length; i++) {
            if (players[i].playerAddress == playerAddress) {
                return players[i].position;
            }
        }
        revert("Player not found");
    }
}
