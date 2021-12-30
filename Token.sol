// SPDX-License-Identifier: GPL-3.0

pragma solidity >=0.7.0 <0.9.0;
import {customLib} from "Libraries.sol";
import "https://github.com/OpenZeppelin/openzeppelin-contracts/blob/master/contracts/utils/math/SafeMath.sol";

contract Token {
    using SafeMath for uint256;
    // variables
    string public name = "Avokado";
    string public symbol = "AVK";
    address owner;
    uint public totalSupply = 1000000;
    uint tokenCirculating = 0;
    mapping(address => uint) balances;
    mapping(address => bool) enrolled;
    uint256 tokenPrice = 9 wei;
    address[] addresses;
    uint members = 0;


    // events
    event Purchase(address buyer, uint256 amount);
    event Transfer(address sender, address receiver, uint256 amount);
    event Sell(address seller, uint256 amount);
    event Price(uint256 price);

    constructor() {
        owner = msg.sender;
        enrolled[owner] = true;
    }

    function join() public returns (string memory){
        if (enrolled[msg.sender] == true){
            return "You're already enrolled";
        } else {
            members += 1;
            balances[msg.sender] = 0;
            enrolled[msg.sender] = true;
            addresses.push(msg.sender);
            return "Congratulations! You're enrolled!";
        }
    }
    function buyToken(uint256 amount) public payable returns (bool) {
        require(enrolled[msg.sender] == true);
        require(tokenCirculating + amount <= totalSupply);
        uint256 price = amount.mul(tokenPrice);
        require(msg.value == price, "Wrong price amount inputted");
        balances[msg.sender] += amount;
        tokenCirculating += amount;
        emit Purchase(msg.sender, amount);
        return true;
    }

    function transfer(address recipient, uint256 amount) public payable returns (bool) {
        require(enrolled[msg.sender] == true);
        require (balances[msg.sender] >= amount, "Not Enough Tokens!");
        balances[msg.sender] -= amount;
        balances[recipient] += amount;
        emit Transfer(msg.sender, recipient, amount);
        return true;
    }

    function sellToken(uint256 amount) public payable returns (bool) {
        require (balances[msg.sender] >= amount, "Not Enough Tokens!");
        require(enrolled[msg.sender] == true);
        require (totalSupply >= amount);
        balances[msg.sender] -= amount;
        totalSupply -= amount;
        uint256 price = amount.mul(tokenPrice);
        customLib.customSend(price, msg.sender);
        emit Sell(msg.sender, amount);
        return true;
    }

    function changePrice(uint256 price) public payable returns (bool){
        require (msg.sender == owner);
        uint i = 0;
        uint totalTokens = 0;
        for(i; i < members; i++) {
            totalTokens += balances[addresses[i]];
        }
        uint256 totalValue = price.mul(totalTokens);
        require(address(this).balance >= totalValue);
        tokenPrice = price;
        emit Price(price);
        return true;
    }

    function getBalance() public view returns (uint256) {
        return balances[msg.sender];
    }

    function computePrice(uint256 amount) public view returns (uint256) {
        return amount.mul(tokenPrice);
    }

    function contractsBalance() public view returns (uint256) {
        return address(this).balance;
    }

    function getTokenPrice() public view returns (uint256) {
        return tokenPrice;
    }

}
