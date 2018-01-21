pragma solidity ^0.4.4;

contract BirdCore{
    function getUserByBirdId(uint) public constant returns (address);
    function getRefer(address) public constant returns (address);
    function birdTransfer(uint, address) public;
}

contract Exchange{
    BirdCore public bird;
    Order[] birdOrders;
    uint birdOrderIndex = 0;
    address coreAddress;
    
    mapping(uint => Order) birdOrderId;
    
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
        // продажа птицы
        if (_type == 0){
            require(bird.getUserByBirdId(_spec) == msg.sender);
            
            Order memory _ord = Order({
                id: birdOrderIndex,
                price: _price,
                seils: msg.sender,
                date: now
            });
            birdOrders.push(_ord);
            
            birdOrderIndex = birdOrderIndex + 1;
            birdOrderId[_spec] = _ord;
        }
        // продажа инвентаря
        else if (_type == 1) {
            
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
    
    function acceptBirdOrder(uint birdId) public payable {
        require(msg.value >= birdOrderId[birdId].price);
        
        //платежки
        //где-то тут косяк
        /*
        uint profit = msg.value/20;
        bird.getUserByBirdId(birdId).transfer(msg.value/20*19);
        bird.getRefer(bird.getUserByBirdId(birdId)).transfer(profit/10);
        coreAddress.transfer((profit/10)*9);*/
            
        bird.birdTransfer(birdId, msg.sender);
        
        delete birdOrderId[birdId];
        delete birdOrders[birdOrderId[birdId].id];
    }
    
    event newOrder(string);
}