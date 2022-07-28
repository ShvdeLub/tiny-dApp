pragma solidity 0.8.9;

contract Auction {
    //propriétés de l'enchère
    address private owner;
    uint public startTime;
    uint public endTime;
    mapping(address => uint) public bids;

    // on défini ici
    // la maison qui sera mise aux enchères

    struct House {
        string houseType;
        string houseColor;
        string houseLocation;
    }

    // on défini ici
    // celui qui a proposé le prix le plus haut

    struct HighestBid {
        uint bidAmount;
        address bidder;
    }

    House public newHouse;
    HighestBid public highestBid;

    modifier isOngoing() {
        require(block.timestamp < endTime,'this auction is closed');
        _;
    }

    modifier notOngoing() {
        require(block.timestamp >= endTime, 'this auction is open');
        _;
    }

    modifier isOwner() {
        require(msg.sender == owner, 'not the owner');
        _;
    }

    modifier isBidder() {
        require(msg.sender != owner, 'Owner is not allowed to bid.');
        _;
    }

    // événements qui permettent au front end d'accèder
    // aux données entrées en paramètres des events

    event LogBid(address indexed _highestBidder, uint _highestBid);
    event LogWithdrawal(address indexed _withdrawer, uint amount);

    // le constructeur n'est appelé qu'une fois, au deploiement du contract
    // on assigne des valuers aux propriétés du contract (comme la durée de l'enchère etc..)

    constructor () {
        owner = msg.sender;
        startTime = block.timestamp;
        endTime = block.timestamp + 1 hours;
        newHouse.houseColor = '#FFFFFF';
        newHouse.houseLocation = 'Paris, France';
        newHouse.houseType = 'flat';
    }

    function makeBid() public payable isOngoing() isBidder() returns(bool) {
        uint bidAmount = bids[msg.sender] + msg.value;
        require(bidAmount > highestBid.bidAmount, 'your bid is lower than the highest one, make a higher bid !');
        highestBid.bidder = msg.sender;
        highestBid.bidAmount = bidAmount;
        bids[msg.sender] = bidAmount;
        emit LogBid(msg.sender, bidAmount);
        return true;
    }

    function withdraw() public notOngoing() isOwner() returns(bool) {
        uint amount = highestBid.bidAmount;
        bids[highestBid.bidder] = 0;
        highestBid.bidder = address(0);
        highestBid.bidAmount = 0;

        (bool success, ) = payable(owner).call{ value: amount }("");
        require(success, 'Withdrawal failed.');
        emit LogWithdrawal(msg.sender, amount);
        return true;
    }
    
    function fetchHighestBid() public view returns (HighestBid memory) {
        HighestBid memory _highestBid = highestBid;
        return _highestBid;
    }

    function getOwner() public view returns (address) {
        return owner;
    } 
}