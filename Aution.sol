// SPDX-License-Identifier: MIT
pragma solidity > 0.8.20;

contract Subasta {

    //variables
    address public owner;
    uint public auctionEndTime;
    uint public highestBid;
    address public highestBidder;

    //CONSTANTS
    uint constant EXTENSION_TIME = 10 minutes;
    uint constant COMMISSION_PERCENT = 2;

    //mappings
    mapping(address => uint) public bids;
    mapping(address => uint[]) public previousOffers;
    mapping(address => uint) public pendingReturns;

    address[] public bidders;
    bool public auctionEnded;
    
    //events
    event NewBid(address indexed bidder, uint amount);
    event AuctionEnded(address winner, uint amount);
    event AuctionExtended(uint newEndTime);
    event Withdraw(address indexed user, uint amount);

    //modifiers
    modifier onlyOwner() {
        require(msg.sender == owner, "Solo el owner puede ejecutar esto");
        _;
    }

    modifier onlyWhileOpen() {
        require(block.timestamp < auctionEndTime, "Subasta finalizada");
        _;
    }

    modifier onlyAfterEnd() {
        require(block.timestamp >= auctionEndTime, "Subasta aun activa");
        _;
    }

    //constructor
    constructor(uint _durationMinutes) payable {
        owner = msg.sender;
        auctionEndTime = block.timestamp + (_durationMinutes * 1 minutes);
        highestBid = msg.value;
        highestBidder = msg.sender;
        bids[msg.sender] = msg.value;
        bidders.push(msg.sender);
        emit NewBid(msg.sender, msg.value);
    }

    //functions
    //ofertar
    function bid() external payable onlyWhileOpen {
        require(msg.value > 0, "Debes enviar un valor mayor a 0");

        uint newBidAmount = bids[msg.sender] + msg.value;
        require(newBidAmount >= highestBid + (highestBid * 5) / 100, "Oferta debe superar al menos 5%");

        if (bids[msg.sender] > 0) {
            previousOffers[msg.sender].push(bids[msg.sender]);
            pendingReturns[msg.sender] += bids[msg.sender];
        } else {
            bidders.push(msg.sender);
        }

        bids[msg.sender] = newBidAmount;

        highestBid = newBidAmount;
        highestBidder = msg.sender;

        emit NewBid(msg.sender, newBidAmount);
        //falta 10 mins?
        if (auctionEndTime - block.timestamp < EXTENSION_TIME) {
            auctionEndTime = block.timestamp + EXTENSION_TIME;
            emit AuctionExtended(auctionEndTime);
        }
    }
    //devolver excedente de ofertas anteriores
    function withdrawExcess() external {
        uint amount = pendingReturns[msg.sender];
        require(amount > 0, "Nada para retirar");
        pendingReturns[msg.sender] = 0;
        (bool sent, ) = payable(msg.sender).call{value: amount}("");
        require(sent, "Fallo en el retiro");
        emit Withdraw(msg.sender, amount);
    }
    //finalizar subasta
    function endAuction() external onlyAfterEnd onlyOwner {
        require(!auctionEnded, "Ya finalizo");
        auctionEnded = true;

        for (uint i = 0; i < bidders.length; i++) {
            address bidder = bidders[i];
            if (bidder != highestBidder) {
                uint refund = bids[bidder] + pendingReturns[bidder];
                if (refund > 0) {
                    bids[bidder] = 0;
                    pendingReturns[bidder] = 0;
                    (bool sent, ) = payable(bidder).call{value: refund}("");
                    require(sent, "Fallo en reembolso");
                }
            }
        }

        uint fee = (highestBid * COMMISSION_PERCENT) / 100;
        uint sellerAmount = highestBid - fee;

        (bool sentToOwner, ) = payable(owner).call{value: sellerAmount}("");
        require(sentToOwner, "Fallo al enviar fondos al owner");

        emit AuctionEnded(highestBidder, highestBid);
    }
    //ver quien va ganando
    function getWinner() external view  returns (address, uint) {
        return (highestBidder, highestBid);
    }
    //ver tiempo
    function getTime() external view returns(uint){
        return (auctionEndTime - block.timestamp);
    }

    //ver ofertas
    function getAllOffers() external view returns (address[] memory, uint[] memory) {
        uint[] memory offerAmounts = new uint[](bidders.length);
        for (uint i = 0; i < bidders.length; i++) {
            offerAmounts[i] = bids[bidders[i]];
        }
        return (bidders, offerAmounts);
    }
    //ofertas previas
    function getPreviousOffers(address bidder) external view returns (uint[] memory) {
        return previousOffers[bidder];
    }
    //El contrato recibe ETH sin datos
    receive() external payable {
        revert("No se permite enviar ETH directamente");
    }
}
