// SPDX-License-Identifier: GPL-3.0
pragma solidity >=0.7.0 <0.9.0;

contract RPSLS {
    uint public numPlayer = 0;
    uint public reward = 0;
    uint public startTime; // เวลาที่เกมเริ่ม
    uint public waitingTimeLimit = 120; // เวลารอผู้เล่นคนที่สอง (120 วินาที)

    mapping(address => uint) public player_choice;
    mapping(address => bool) public player_not_played;
    address[] public players;

    uint public numInput = 0;
    uint public timeLimit = 60; // เวลาสำหรับเลือก (60 วินาที)
    uint public revealTimeLimit = 60; // เวลาสำหรับเปิดเผยค่า (60 วินาที)

    function addPlayer() public payable {
        require(numPlayer < 2, "Game is full");
        require(msg.value == 1 ether, "Must send exactly 1 ether");

        if (numPlayer > 0) {
            require(msg.sender != players[0], "Same player cannot join twice");
        }

        reward += msg.value;
        players.push(msg.sender);
        numPlayer++;

        if (numPlayer == 1) {
            startTime = block.timestamp; // เริ่มจับเวลารอผู้เล่นที่สอง
        } else if (numPlayer == 2) {
            startTime = block.timestamp; // รีเซ็ตเวลาเริ่มต้นเมื่อครบ 2 คน
        }
    }

    function refundIfNoOpponent() public {
        require(numPlayer == 1, "Cannot refund, game already started");
        require(block.timestamp > startTime + waitingTimeLimit, "Waiting time not exceeded");

        address payable player = payable(players[0]);
        player.transfer(reward);

        _resetGame();
    }

    function _resetGame() private {
        numPlayer = 0;
        numInput = 0;
        reward = 0;
        startTime = 0;
        delete players;
    }
}
