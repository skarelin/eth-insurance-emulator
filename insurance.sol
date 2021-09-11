pragma solidity ^0.6.0;


contract Authorized {
    address broker;
    address insured;
    
    modifier onlyAuthorized() {
        require(msg.sender == insured || msg.sender == broker, "Permission denied");
        _;
    }
    
    modifier onlyBroker() {
        require(msg.sender == broker, "Permission denied");
        _;
    }
    
    modifier onlyInsured() {
        require(msg.sender == insured, "Permission denied for the broker. It's user's personal data.");
        _;
    }
    
    constructor(address _insured) public {
        require(msg.sender != address(_insured), "You can't create policy for yourself!");
        broker = msg.sender;
        insured = _insured;
    }
}


contract PremiumPolicy {
    
    enum PremiumStatus { None, Bronze, Silver, Gold }
    PremiumStatus currentStatus;
    
    constructor() public {
        currentStatus = PremiumStatus.None;
    }
    
    
    function setStatus(uint _status) public {
        currentStatus = PremiumStatus(_status);
    }
    
    
    function getDiscount() public view returns(uint256) {
        if(currentStatus == PremiumStatus.Bronze) {
            return 50;
        } else if(currentStatus == PremiumStatus.Silver) {
            return 150;
        } else if(currentStatus == PremiumStatus.Gold) {
            return 500;
        } else {
            return 0;
        }
    }
}

contract Policy is Authorized {
    
    
    bool isPolicyActivated = false;
    bool isPolicyPaid = false;
    uint256 policyPrice = 0;
    PremiumPolicy premiumPolicy = new PremiumPolicy();
    
    
    string insuredName = "Empty";
    string insuredIdNumber = "Empty";
    
    
    uint256 developmentVersion = 3595;
    
    constructor(address _insured, uint256 _policyPrice) public Authorized(_insured) {
        require(_policyPrice >= 1000, "Policy price can't be cheaper than 1000$!");
        policyPrice = _policyPrice;
    }
    
    
    function getInsured() public view onlyAuthorized returns(address) {
        return insured;
    }
    
    
    function setInsuredPersonalData(string memory _insuredName, string memory _insuredIdNumber) public onlyInsured {
        insuredName = _insuredName;
        insuredIdNumber = _insuredIdNumber;
    }
    
    
    function getInsuredPersonalData() public view onlyInsured returns(string memory) {
        return cancat(insuredName, insuredIdNumber);
    }
    
    
    function activatePolicy() public onlyBroker {
        require(compareStrings(insuredName, "Empty") == false, "Insured name is not provided. Contact your client.");
        require(compareStrings(insuredIdNumber, "Empty") == false, "Insured id number is not provided. Contact your client.");
        require(isPolicyPaid == true, "Policy hasn't been paid yet! Contact with insured.");
        isPolicyActivated = true;
    }
    
    
    function deactivatePolicy() public onlyBroker {
        require(isPolicyActivated == true, "Policy is not activated yet!");
        isPolicyActivated = false;
    }
    
    
    function getPolicyStatus() public view onlyAuthorized returns(bool) {
        return isPolicyActivated;
    }
    
    
    function getMyRole() public view onlyAuthorized returns(string memory) {
        if(broker == msg.sender) {
            return "You are broker.";
        } else if(insured == msg.sender) {
            return "You are insured.";
        } else {
            return "Permission denied.";
        }
    }
    
    
    function getPolicyPrice() public view onlyAuthorized returns(uint256) {
        return policyPrice - premiumPolicy.getDiscount();
    }
    
    
    function payForPolice(uint256 payPalMoney) public onlyInsured {
        uint priceWithDiscount = policyPrice-premiumPolicy.getDiscount();
        require(payPalMoney == priceWithDiscount, "You have not enough money or provided money amount is not correct!");
        isPolicyPaid = true;
    }
    
    
    function setPremiumForPolicy(uint _premiumStatus) public onlyBroker {
        premiumPolicy.setStatus(_premiumStatus);
    }
    
    
    function getVersion() public view onlyBroker returns(uint256) {
        return developmentVersion;
    }
    
    
    
    
    //UTILS ==================================
    function cancat(string memory a, string memory b) private pure returns(string memory){
        return(string(abi.encodePacked(a," ",b)));
    }
    
    
    function compareStrings(string memory a, string memory b) private pure returns (bool) {
        return (keccak256(abi.encodePacked((a))) == keccak256(abi.encodePacked((b))));
    }

    
}
