// SPDX-License-Identifier: MIT
pragma solidity >0.8.20;

contract Subasta {

    address public owner;
    uint public auctionEndTime;
    uint public highestBid;
    address public highestBidder;

    mapping(address => uint) public bids;
    mapping(address => uint[]) public previousOffers;
    mapping(address => uint) public pendingReturns;

    address[] public bidders;

    bool public auctionEnded;

    uint constant EXTENSION_TIME = 10 minutes;

    event NewBid(address indexed bidder, uint amount);
    event AuctionExtended(uint newEndTime);
    event AuctionEnded(address winner, uint amount);
    event PartialRefundWithdrawn(address bidder, uint amount);

    modifier onlyWhileOpen() {
        require(block.timestamp < auctionEndTime, "Subasta finalizada");
        _;
    }

    modifier onlyWhileActive() {
        require(block.timestamp < auctionEndTime, "La subasta ya finalizo");
        _;
    }

    modifier onlyAfterEnd() {
        require(block.timestamp >= auctionEndTime, "La subasta aun esta activa");
        _;
    }

    modifier onlyNotHighest() {
        require(msg.sender != highestBidder, "El ganador no puede retirar fondos aun");
        _;
    }

    constructor(uint _durationMinutes) {
        owner = msg.sender;
        auctionEndTime = block.timestamp + (_durationMinutes * 1 minutes);
    }

    function bid() external payable onlyWhileOpen {
        require(msg.value > 0, "Debes enviar un valor mayor a 0");

        uint newBidAmount = bids[msg.sender] + msg.value;

        // Primera oferta
        if (highestBid == 0) {
            require(newBidAmount > 0, "La oferta debe ser mayor que cero");
        } else {
            require(newBidAmount >= highestBid + (highestBid * 5) / 100, "Oferta debe superar la mejor en al menos 5%");
        }

        // Guardar oferta anterior para reembolso parcial
        if (bids[msg.sender] > 0) {
            uint previousBid = bids[msg.sender];
            previousOffers[msg.sender].push(previousBid);

            // Acumular reembolso
            pendingReturns[msg.sender] += previousBid;
        } else {
            // Nuevo oferente
            bidders.push(msg.sender);
        }

        bids[msg.sender] = newBidAmount;

        // Actualizar oferta más alta si corresponde
        if (newBidAmount > highestBid) {
            highestBid = newBidAmount;
            highestBidder = msg.sender;
        }

        emit NewBid(msg.sender, newBidAmount);

        // Extender subasta si queda menos de 10 minutos
        if (auctionEndTime - block.timestamp < EXTENSION_TIME) {
            auctionEndTime += EXTENSION_TIME;
            emit AuctionExtended(auctionEndTime);
        }
    }

    function getAllOffers() external view returns (address[] memory, uint[] memory) {
        uint[] memory amounts = new uint[](bidders.length);
        for (uint i = 0; i < bidders.length; i++) {
            amounts[i] = bids[bidders[i]];
        }
        return (bidders, amounts);
    }

    function endAuction() external onlyAfterEnd {
        require(!auctionEnded, "La subasta ya fue finalizada");
        auctionEnded = true;

        // Reembolsar a todos excepto al ganador
        for (uint i = 0; i < bidders.length; i++) {
            address bidder = bidders[i];
            if (bidder != highestBidder) {
                uint refund = bids[bidder];
                if (refund > 0) {
                    bids[bidder] = 0;
                    payable(bidder).transfer(refund);
                }
            }
        }

        // Comisión 2%
        uint fee = (highestBid * 2) / 100;
        uint sellerAmount = highestBid - fee;

        // Transferir al propietario (vendedor)
        payable(owner).transfer(sellerAmount);

        emit AuctionEnded(highestBidder, highestBid);
    }

    function withdrawPartialRefund() external onlyWhileActive onlyNotHighest {
        uint amount = pendingReturns[msg.sender];
        require(amount > 0, "No hay fondos pendientes para retirar");

        pendingReturns[msg.sender] = 0;

        (bool sent, ) = payable(msg.sender).call{value: amount}("");
        require(sent, "Error al realizar el reembolso");

        emit PartialRefundWithdrawn(msg.sender, amount);
    }
}
