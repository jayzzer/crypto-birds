pragma solidity ^0.4.19;

contract BirdCore{
    function getUserByBirdId(uint) public constant returns (address);
    function getUserByEquipId(uint) public constant returns (address);
    function getRefer(address) public constant returns (address);
    function birdTransfer(uint, address) public;
    function equipTransfer(uint, address) public;
}

contract Exchange{
    BirdCore public bird;
    Order[] birdOrders;
    uint birdOrderIndex = 0;
    Order[] equipOrders;
    uint equipOrderIndex = 0;
    address coreAddress;
    
    mapping(uint => Order) birdOrderId;
    mapping(uint => Order) equipOrderId;
    
    struct Order{
        uint id;
        uint price;
        uint date;
        address seils;
    }
    
    function Exchange(address _core) public {
        bird = BirdCore(_core);
        coreAddress = _core;
    }
    
    function addNewOrder(uint _type ,uint _spec, uint _price) public {
        Order memory _ord;
        // продажа птицы
        if (_type == 0){
            require(bird.getUserByBirdId(_spec) == msg.sender);
            
           _ord = Order({
                id: birdOrderIndex,
                price: _price,
                seils: msg.sender,
                date: now
            });
            birdOrders.push(_ord);
            
            birdOrderIndex = birdOrderIndex + 1;
            birdOrderId[_spec] = _ord;
        }
        // продажа экипировки
        else if (_type == 1) {
            require(bird.getUserByEquipId(_spec) == msg.sender);
            
            _ord = Order({
                id: equipOrderIndex,
                price: _price,
                seils: msg.sender,
                date: now
            });
            equipOrders.push(_ord);
            
            equipOrderIndex = equipOrderIndex + 1;
            equipOrderId[_spec] = _ord;
        } 
        // продажа корзин
        else if (_type == 2){
            
        }
    }
    
    function closeOrder(uint _type, uint _spec) public {
        if (0 == _type){
            require(birdOrderId[_spec].seils == msg.sender);
            delete birdOrderId[_spec];
            delete birdOrders[birdOrderId[_spec].id];
        }

        else if (1 == _type){
            require(equipOrderId[_spec].seils == msg.sender);
            delete equipOrderId[_spec];
            delete equipOrders[equipOrderId[_spec].id];
        }
        
        else if (2 == _type){
            
        }
    }
    
    function getByBirdId(uint birdId) public constant returns(address seils, uint price, uint date) {
        return (birdOrderId[birdId].seils, birdOrderId[birdId].price, birdOrderId[birdId].date);
    }
    
    function getByBirdOrdeId(uint index) public constant returns(address seils, uint price, uint date) {
        return (birdOrders[index].seils, birdOrders[index].price, birdOrders[index].date);
    }
    
    function getOrdersLength() public constant returns(uint) {
        return birdOrderIndex;
    }
    
    function payForItem(address to, uint value) internal {
        uint profit = value/20;
        to.transfer(value-profit);
        
        //платежки
        //где-то тут косяк
        // uint profit = msg.value/20;
        // bird.getUserByBirdId(birdId).transfer(msg.value/20*19);
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
        
        address to = bird.getUserByBirdId(birdId);
        payForItem(to, msg.value);
        
        bird.birdTransfer(birdId, msg.sender);
        
        delete birdOrderId[birdId];
        delete birdOrders[birdOrderId[birdId].id];
    }
    
    function acceptEquipOrder(uint equipId) public payable {
        require(msg.value >= equipOrderId[equipId].price);
        
        address to = bird.getUserByEquipId(equipId);
        payForItem(to, msg.value);
            
        bird.equipTransfer(equipId, msg.sender);
        
        delete equipOrderId[equipId];
        delete equipOrders[equipOrderId[equipId].id];
    }
    
    event newOrder(string);
}