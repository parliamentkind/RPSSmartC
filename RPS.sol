// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract RockPaperScissors {
    address public owner;
    uint256 public gameCount;
    
    enum Move { None, Rock, Paper, Scissors }
    
    struct Game {
        uint256 gameId;
        address player;
        Move playerMove;
        Move houseMove;
        uint256 betAmount;
        uint256 rewardAmount;
        bool hasEnded;
    }
    
    mapping(uint256 => Game) public games;
    
    event GamePlayed(uint256 indexed gameId, address indexed player, Move playerMove, Move houseMove, uint256 betAmount, uint256 rewardAmount);
    
    constructor() {
        owner = msg.sender;
        gameCount = 0;
    }
    
    function play(uint256 _move) external payable {
        // Convert 0.0001 tBNB to wei (1 BNB = 10^18 wei)
        uint256 requiredAmount = 100000000; // 0.0001 BNB in wei
        
        require(msg.value == requiredAmount, "Please send 0.0001 tBNB to play.");
        require(_move >= uint256(Move.Rock) && _move <= uint256(Move.Scissors), "Invalid move.");
        
        uint256 gameId = gameCount;
        gameCount++;
        
        Move playerMove = Move(_move);
        Move houseMove = generateRandomMove();
        uint256 rewardAmount = 0;
        
        if (playerMove == houseMove) {
            // Draw, refund the player's bet
            payable(msg.sender).transfer(msg.value);
        } else if (
            (playerMove == Move.Rock && houseMove == Move.Scissors) ||
            (playerMove == Move.Paper && houseMove == Move.Rock) ||
            (playerMove == Move.Scissors && houseMove == Move.Paper)
        ) {
            // Player wins, send reward (2x the bet)
            rewardAmount = msg.value * 2;
            payable(msg.sender).transfer(rewardAmount);
        } else {
            // Player loses, no reward
        }
        
        games[gameId] = Game({
            gameId: gameId,
            player: msg.sender,
            playerMove: playerMove,
            houseMove: houseMove,
            betAmount: msg.value,
            rewardAmount: rewardAmount,
            hasEnded: true
        });
        
        emit GamePlayed(gameId, msg.sender, playerMove, houseMove, msg.value, rewardAmount);
    }
    
    function generateRandomMove() internal view returns (Move) {
        uint256 seed = uint256(keccak256(abi.encodePacked(block.timestamp, block.difficulty, msg.sender)));
        return Move(seed % 3 + 1); // 1: Rock, 2: Paper, 3: Scissors
    }
    
    function getGameHistory() external view returns (Game[] memory) {
        Game[] memory history = new Game[](gameCount);
        for (uint256 i = 0; i < gameCount; i++) {
            history[i] = games[i];
        }
        return history;
    }
}
