// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/access/Ownable.sol";

struct Maze {
    bool created;
    uint8[][] cells;
    bool success;
    uint256 startTimestamp;
    uint256 endTimestamp;
}

contract RandomMaze is Ownable {

    mapping(address => Maze) public mazes;
    mapping(address => uint256) public balances;

    address[] public users;

    modifier mazeExistForUser(address _user) {
        require(mazes[_user].created, "no maze has been generated for this user");
        _;
    }

    event MazeGenerated(address indexed _user, uint256 startTimestamp);
    event MazeCompleted(address indexed _user, uint256 endTimestamp, bool winOrLose);

    constructor() Ownable(msg.sender) { }

    function generateMaze(address _user, uint8[] calldata _flattedCells,
    uint8 _rows, uint8 _cols) onlyOwner() external {
        require(_flattedCells.length == _rows * _cols, "array of cells are not correct");

        uint8[][] memory cells = new uint8[][](_rows);

        // пересобираем cells


        // если пользователь еще не создавал лабиринт - добавляем в список пользователей
        if (!mazes[_user].created) {
            users.push(_user);
        }

        mazes[_user] = Maze({
            created: true,
            cells: cells,
            success: false,
            startTimestamp: block.timestamp,
            endTimestamp: 0
        });

        emit MazeGenerated(msg.sender, block.timestamp);
    }

    function completeMaze(address _user, bool _success) mazeExistForUser(_user) onlyOwner() external {
        Maze storage currentMaze = mazes[_user];

        uint256 endTimestamp = block.timestamp;
        currentMaze.endTimestamp = endTimestamp;
        currentMaze.success = _success;

        emit MazeCompleted(_user, endTimestamp, _success);
    }

    // function getCell(address _user, uint8 _row, uint8 _col) public view mazeExistForUser(_user)
    // returns (uint8) {
    //     return mazes[_user].cells[_row][_col];
    // }

    function getAllMazes() view external returns (address[] memory, Maze[] memory) {
        Maze[] memory mazesArr = new Maze[](users.length);

        for (uint256 i = 0; i < users.length; i++) {
            mazesArr[i] = mazes[users[i]];
        }

        return (users, mazesArr);
    }

    function getUserMaze(address _user) mazeExistForUser(_user) view external returns (Maze memory) {
        return mazes[_user];
    }

    // функция доната на контракт и функция снятия денег для овнера
}