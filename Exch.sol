pragma solidity ^0.4.19;

contract BirdCore{
    function getUserByBirdId(uint) public constant returns (address);
    function getUserByEquipId(uint) public constant returns (address);
    function getRefer(address) public constant returns (address);
    function birdTransfer(uint, address) public;
    function equipTransfer(uint, address) public;
}

contract Exchange{
    uint[] lvlTable = [
        0,
        10,
        25,
        50,
        100,
        250,
        500,
        1000,
        1600,
        2300,
        3100,
        4000,
        5000,
        6100,
        7300,
        8600,
        10000,
        11500,
        13100,
        14800,
        16600,
        18500,
        20500,
        22600,
        24700,
        26900,
        29200,
        31600,
        34100,
        36700
    ];
    
    uint[] equipProbab = [
        0,
        234,
        468,
        703,
        
        770,
        833,
        896,
        
        906,
        916,
        926,
        
        929
    ];
    
    BirdCore public bird;
    Order[] birdOrders;
    uint birdOrderIndex = 0;
    Order[] equipOrders;
    uint equipOrderIndex = 0;
    address coreAddress;
    
    mapping(uint => Order) birdOrderId;
    mapping(uint => Order) equipOrderId;
    
    mapping(address => uint) userSells;
    mapping(address => uint) userPurchases;
    
    struct Order{
        uint id;
        uint spec;
        uint price;
        uint date;
        address seils;
        address receiver;
    }
    
    function Exchange(address _core) public {
        bird = BirdCore(_core);
        coreAddress = _core;
    }
    
    function genEquipLvl(uint randNum) public constant returns (uint) {
        uint resLvl = 1;

        for (uint i = 0; i < equipProbab.length; i++) {
            if (randNum >= equipProbab[i] && randNum < equipProbab[i+1]) {
                resLvl = i+1;
                break;
            }
        }
        
        return resLvl;
    }
    
    function getBirdLvl(uint _level, uint _exp) public constant returns(uint) {
        for (uint i = _level-1; i < lvlTable.length; i++) {
            if (_exp >= lvlTable[i] && _exp < lvlTable[i+1]) {
                return i+1;
            }
        }
    }
    
    function addNewOrder(uint _type ,uint _spec, uint _price, address _receiver) public {
        Order memory _ord;
        require(_price > 0);
        // продажа птицы
        if (_type == 0){
            require(bird.getUserByBirdId(_spec) == msg.sender);
            require(!isBirdOnExch(_spec));
            
            _ord = Order({
                id: birdOrderIndex,
                spec: _spec,
                price: _price,
                seils: msg.sender,
                receiver: _receiver,
                date: now
            });
            birdOrders.push(_ord);
            
            birdOrderIndex = birdOrderIndex + 1;
            birdOrderId[_spec] = _ord;
        }
        // продажа экипировки
        else if (_type == 1) {
            require(bird.getUserByEquipId(_spec) == msg.sender);
            require(!isEquipOnExch(_spec));
            
            _ord = Order({
                id: equipOrderIndex,
                spec: _spec,
                price: _price,
                seils: msg.sender,
                receiver: _receiver,
                date: now
            });
            equipOrders.push(_ord);
            
            equipOrderIndex = equipOrderIndex + 1;
            equipOrderId[_spec] = _ord;
        } 

    }
    
    function closeOrder(uint _type, uint _spec) public {
        if (0 == _type){
            require(birdOrderId[_spec].seils == msg.sender);
            delete birdOrderId[_spec];
            //delete birdOrders[birdOrderId[_spec].id];
            delBirdOrder(birdOrderId[_spec].id);
        }

        else if (1 == _type){
            require(equipOrderId[_spec].seils == msg.sender);
            delete equipOrderId[_spec];
            //delete equipOrders[equipOrderId[_spec].id];
            delEquipOrder(equipOrderId[_spec].id);
        }
        
    }
    
    function isBirdOnExch(uint _birdId) public constant returns(bool) {
        if (birdOrderId[_birdId].date != 0 ) return true;
        return false;
    }
    
    function isEquipOnExch(uint _equipId) public constant returns(bool) {
        if (equipOrderId[_equipId].date != 0 ) return true;
        return false;
    }
    
    function getByBirdId(uint birdId) public constant returns(address seils, uint price, uint date) {
        return (birdOrderId[birdId].seils, birdOrderId[birdId].price, birdOrderId[birdId].date);
    }
    
    function getByBirdOrdeId(uint index) public constant returns(address seils, uint price, uint date, uint spec, address receiver) {
        return (birdOrders[index].seils, birdOrders[index].price, birdOrders[index].date, birdOrders[index].spec, birdOrders[index].receiver);
    }
    
    function getByEquipOrderId(uint index) public constant returns(address seils, uint price, uint date, uint spec, address receiver) {
        return (equipOrders[index].seils, equipOrders[index].price, equipOrders[index].date, equipOrders[index].spec, equipOrders[index].receiver);
    }
    
    function getOrdersLength() public constant returns(uint) {
        return birdOrders.length;
    }
    
    function getEquipOrdersLength() public constant returns(uint) {
        return equipOrders.length;
    }
    
    function getUserSells(address _user) external constant returns(uint sells) {
        return userSells[_user];
    }
    
    function getUserPurchases(address _user) external constant returns(uint purchases) {
        return userPurchases[_user];
    }
    
    function payForItem(address to, uint value) internal {
        uint profit = value/20;
        to.transfer(value-profit);
        
        address refer = bird.getRefer(to);
        uint referProfit = 0;
        if (refer != address(0)) {
            referProfit = profit/10;
            refer.transfer(referProfit);
        }
        
        coreAddress.send(profit-referProfit);
    }
    
    function acceptBirdOrder(uint birdId) public payable {
        require(msg.value >= birdOrderId[birdId].price);
        
        if (birdOrderId[birdId].receiver != address(0)) {
            require(msg.sender == birdOrderId[birdId].receiver);
        }
        
        address to = bird.getUserByBirdId(birdId);
        payForItem(to, msg.value);
        
        bird.birdTransfer(birdId, msg.sender);
        
        exchangeSells(msg.sender, ++userSells[to]);
        exchangePurchases(msg.sender, ++userPurchases[msg.sender]);
        
        delBirdOrder(birdOrderId[birdId].id);
        delete birdOrderId[birdId];
        //delete birdOrders[birdOrderId[birdId].id];;
    }
    
    function acceptEquipOrder(uint equipId) public payable {
        require(msg.value >= equipOrderId[equipId].price);
        
        if (birdOrderId[birdId].receiver != address(0)) {
            require(msg.sender == birdOrderId[birdId].receiver);
        }
        
        address to = bird.getUserByEquipId(equipId);
        payForItem(to, msg.value);
            
        bird.equipTransfer(equipId, msg.sender);
        
        exchangeSells(msg.sender, ++userSells[to]);
        exchangePurchases(msg.sender,++userPurchases[msg.sender]);
        
        delEquipOrder(equipOrderId[equipId].id);
        delete equipOrderId[equipId];
        //delete equipOrders[equipOrderId[equipId].id];
    }
    
    function delBirdOrder(uint i) private {
        delete birdOrders[i];
        
        if (birdOrders.length>1) {
            birdOrders[i] = birdOrders[birdOrders.length-1];
        }
        birdOrders.length--;
        birdOrderIndex--;
    }
    
    function delEquipOrder(uint i) private {
        delete equipOrders[i];
        
        if (equipOrders.length>1) {
            equipOrders[i] = equipOrders[equipOrders.length-1];
        }
        equipOrders.length--;
        equipOrderIndex--;
    }
    
    event exchangePurchases(address user, uint n); //n-ое кол-во покупок на бирже
    event exchangeSells(address user, uint n); //n-ое кол-во продаж на бирже
}