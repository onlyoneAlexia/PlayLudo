// SPDX-License-Identifier: SEE LICENSE IN LICENSE
pragma solidity ^0.8.24;


contract Ludogame{

struct playerdetails{
address playersAddress;
uint256 positions; //this holds the turns/ position of players
bool hasstarted;
};
 event PlayerJoined(address indexed player, uint256 number);
    event DiceRolled(address indexed player, uint256 newPosition);
    event GameWon(address indexed player);

    constructor() {
        currentTurn = 0; // Start with the first player
        totalPlayers = 0; // Initialize total players
    }
 function joinGame() public {
        require(totalPlayers < 4, "Maximum players reached");
        players.push(Player(msg.sender, 0, false));
        totalPlayers++;
        emit PlayerJoined(msg.sender);
    }

    function rollDice() public returns (uint256) {
        require(msg.sender == players[currentTurn].playerAddress, "Not your turn");

        // Generate a pseudorandom number between 1 and 6
        uint256 randomNumber = (uint256(keccak256(abi.encodePacked(block.timestamp, block.difficulty, currentTurn, msg.sender))) % 6) + 1;

        // Move the player
        movePlayer(randomNumber);

        emit DiceRolled(msg.sender, randomNumber);
        return randomNumber;
    }

    function movePlayer(uint256 steps) internal {
        Player storage player = players[currentTurn];

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
            emit GameWon(msg.sender);
        }

        emit PlayerMoved(msg.sender, player.position);

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

    function getCurrentPlayer() public view returns (address) {
        return players[currentTurn].playerAddress;
    }

    function getTotalPlayers() public view returns (uint256) {
        return totalPlayers;
    }
}

}