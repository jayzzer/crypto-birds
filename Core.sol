pragma solidity ^0.4.19;


contract Random {
    uint nonce = 0;
    function rand(uint min, uint max, uint _prev) internal returns (uint){
        ++nonce;
        random(nonce);
        //+now
        uint randomNumber = uint(keccak256(nonce, now, _prev))%(min+max)-min;
        random(randomNumber);
        return randomNumber;
    }
    
    event random(uint num);
}

contract Achievments {
    event storePurchases(uint n); //n-ое кол-во покупок в магазине
    event exchangePurchases(uint n); //n-ое кол-во покупок на бирже
    event exchangeSells(uint n); //n-ое кол-во продаж на бирже
    event birdLvlUp(uint n); //достижение питомцем n-го уровня
}

contract BirdBase is Random, Achievments{
    uint[] lvlTable = [
        0,
        5,
        50,
        100,
        250
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
    
    //Хар-ки птицы
    struct BirdChar {
        //интервал, определяющий тип птицы
        uint start; 
        uint end;
        
        uint hp;
        uint strength;
        uint strengthUpgr;
        uint protection;
        
        uint spec1;
        uint spec2;
    }
    
    BirdChar[] birdsChar;
    
    uint birdIndex = 0;
    uint eqIndex = 0;
    
    //id -> bird
    mapping (uint => Bird) allBirds;
    mapping (uint => address) birdOwner;
    
    struct Bird {
        uint id;
        uint birdType;
        
        uint level;
        uint experience;
        
        uint zeroHpTime;
        
        uint win;
        uint lose;
        uint draw;
    }
    
    mapping (uint => Equipment) equips;
    mapping (uint => address) equipOwner;
    
    struct Equipment {
        uint id;
        
        uint equipmentType;
        uint itemLvl;
        uint value;
    }
    
    function bornBird (address _user) internal returns(uint){
        Bird memory newBird;
        newBird.id = birdIndex++;
        newBird.birdType = rand(0,108, newBird.id);
        
        newBird.level = 1;
        newBird.experience = 0;
        
        // newBird.totalHP = 10;
        newBird.zeroHpTime = 0;
        
        newBird.win = 0;
        newBird.lose = 0;
        newBird.draw = 0;
        
        // newBird.strength = 1;
        // newBird.protection = 1;
        
        allBirds[newBird.id] = newBird;
        birdOwner[newBird.id] = _user;
        
        return newBird.id;
    }
    
    function getBirdIndex() public constant returns(uint){
        return birdIndex;
    }
    
    //Больше не нужно, так как вынесли получение хар-ик в геттеры
    // function initBirdChar(uint _birdId) internal {
    //     Bird storage foundBird = allBirds[_birdId];
        
    //     for (uint i=0; i < birdsChar.length; i++) {
    //         if (foundBird.birdType >= birdsChar[i].start && foundBird.birdType <= birdsChar[i].end) {
    //             foundBird.totalHP = birdsChar[i].hp;
    //             foundBird.strength = birdsChar[i].strength;
    //             foundBird.protection = birdsChar[i].protection;
                
    //             break;
    //         }
    //     }
    // }
    
    function genEquipment(address _user) public returns(uint){
        uint lvlRand = rand(0, 930, equip.id);
        uint equipLvl = genEquipLvl(lvlRand);
        
        Equipment memory equip = Equipment({
            id: eqIndex++,
            
            equipmentType: rand(0, 2, equip.id),
            itemLvl: equipLvl,
            value: getEquipValue(equipLvl)
        });
        
        
        equips[equip.id] = equip;
        equipOwner[equip.id] = _user;
        
        return equip.id;
    }
    
    function getEquipValue(uint lvl) internal constant 
    returns(uint) {
        return (lvl+1)*5;
    }
    
    function genEquipLvl(uint randNum) internal constant returns (uint) {
        uint resLvl = 1;
        for (uint i = 0; i < equipProbab.length; i++) {
            if (randNum >= equipProbab[i] && randNum < equipProbab[i+1]) {
                resLvl = i+1;
                break;
            }
        }
        
        return resLvl;
    }
    
    function getEquip(uint _id) 
    external constant 
    returns (
        uint equipmentType,
        uint itemLvl,
        uint value
    ) {
        return (equips[_id].equipmentType, equips[_id].itemLvl, equips[_id].value);
    }
    
    function getBird(uint _id) public constant returns(
        address owner,
        uint id,
        uint birdType,
        uint level,
        uint experience,
        uint totalHP,
        uint win
        /*uint lose,
        uint strength,
        uint protection*/
    ){
        return (birdOwner[_id], allBirds[_id].id, allBirds[_id].birdType, allBirds[_id].level, allBirds[_id].experience,getBirdHP(_id), allBirds[_id].win/*,allBirds[_id].lose,allBirds[_id].strength,allBirds[_id].protection*/);
    }
    
    function updateBirdLvl(uint _birdId) internal {
        Bird storage foundBird = allBirds[_birdId];
        
        for (uint i = foundBird.level; i < lvlTable.length; i++) {
            if (foundBird.experience >= lvlTable[i] && foundBird.experience < lvlTable[i+1]) {
                foundBird.level = i+1;
            }
        }
        
        birdLvlUp(foundBird.level);
    }
    
    function getBirdType (uint _birdId) public constant
    returns(uint birdType) {
        Bird storage foundBird = allBirds[_birdId];
        
        for (uint i=0; i < birdsChar.length; i++) {
            if (foundBird.birdType >= birdsChar[i].start && foundBird.birdType <= birdsChar[i].end) {
                return i+1;
            }
        }
    }
    
    function getBirdHP (uint _birdId) public constant 
    returns (uint hp) {
        Bird storage foundBird = allBirds[_birdId];
        uint birdType = getBirdType(_birdId);
        
        return birdsChar[birdType-1].hp * foundBird.level;
    }
    
    function getBirdStrength (uint _birdId) public constant
    returns (uint strength) {
        Bird storage foundBird = allBirds[_birdId];
        uint birdType = getBirdType(_birdId);
        
        return birdsChar[birdType-1].strength + birdsChar[birdType-1].strengthUpgr*(foundBird.level-1);
    }
    
    function getBirdProtection (uint _birdId) public constant
    returns (uint protection) {
        Bird storage foundBird = allBirds[_birdId];
        uint birdType = getBirdType(_birdId);
    
        return birdsChar[birdType-1].protection * foundBird.level;
    }
}

contract User is BirdBase {
    uint initMaxItems;
    uint maxBaskets;
    uint basketPrice;
    uint potionPrice;
    uint upgrInvPrice;
    uint eatExp;
    
    struct user{
        string email;
        string name;
        address refer;
        
        //INVENTORY
        uint birds;
        uint equipments;
        uint eats;
        uint baskets;
        uint potions;
        uint regDate;
        
        uint maxItems;
    }
    
    uint userIndex;
    mapping (address => user) users;
    mapping (uint => address) usersId;
    
    function regUser(string name, string email, address refer) external {
        bool nonReg = true;
        
        for (uint i=0; i<=userIndex; i++){
            if (keccak256(users[usersId[i]].email) == keccak256(email) || usersId[i] == msg.sender){
                nonReg = false;
                error('This email already registered', msg.sender);
            }
        }
        
        if (nonReg) {
            userIndex = userIndex+1;
            usersId[userIndex] = msg.sender;
            
            users[msg.sender].name = name;
            users[msg.sender].email = email;
            users[msg.sender].refer = refer;
            users[msg.sender].regDate = now;
            
            users[msg.sender].eats = 0;
            //users[msg.sender].eats = setEat(0);
            users[msg.sender].baskets = 0;
            users[msg.sender].potions = 0;
            
            users[msg.sender].maxItems = initMaxItems;
        }
    }
    
    function getUserDataByAddress(address _user)
    external constant
    returns (
        string email,
        string name
    ){
        return (users[_user].email, users[_user].name);
    }
    
    function getUserInventoryByAddress(address _user) 
    external constant 
    returns (
        uint birds,
        uint equipments,
        uint eats,
        uint baskets,
        uint potions,
        
        uint maxItems,
        uint itemsCount
    ) {
        return (users[_user].birds,
            users[_user].equipments,
            getEat(_user),
            users[_user].baskets,
            users[_user].potions,
            
            users[_user].maxItems,
            getItemsCount(_user)
        );
    }
    
    function getItemsCount(address _user) internal constant returns (uint itemsCount) {
        user storage userData = users[_user];
        
        return userData.birds + 
            userData.equipments + 
            userData.eats + 
            userData.baskets + 
            userData.potions;
    }
        
    function getUserByID(uint _id) public constant returns (string name, string email, address _address) {
        return (users[usersId[_id]].name, users[usersId[_id]].email, usersId[_id]);
    }
    
    function getUserIndex() public constant returns (uint index){
        return userIndex;
    }
    
    function getEat(address _user) internal returns(uint){
        uint _daily = (now-users[_user].regDate)/100;//86400;
        users[_user].regDate = now;
        
        if (users[_user].maxItems >= (getItemsCount(_user) + _daily))
            users[_user].eats = _daily + users[_user].eats;
        else
            users[_user].eats = users[_user].eats + users[_user].maxItems - getItemsCount(_user);
            
        return users[_user].eats;
    }
    
    function upgradeInventory () external payable {
        user storage userData = users[msg.sender];
        require(userData.maxItems > 0);//maxItems>0 - проверка на регистрацию
        require(userData.maxItems < 30); //Ограничение на расширение(если вдруг нужно)
        require(msg.value == upgrInvPrice);
        
        userData.maxItems += 5;
    }
    
    function buyPotion() external payable {
        user storage userData = users[msg.sender];
        require(userData.maxItems > 0);//maxItems>0 - проверка на регистрацию
        require(userData.maxItems - getItemsCount(msg.sender) >= 1);
        require(msg.value >= potionPrice);
        
        if (users[msg.sender].refer != msg.sender) {
            users[msg.sender].refer.transfer(msg.value/10);
        }
        
        uint _potions = msg.value/potionPrice;
        if ((userData.maxItems - getItemsCount(msg.sender)) >= _potions)
            userData.potions += _potions;
        else
            userData.potions += (userData.maxItems - getItemsCount(msg.sender));
    }
    
    function buyBasket() external payable {
        require(msg.value >= basketPrice);
        user storage userData = users[msg.sender];
        require(userData.maxItems > 0);//maxItems>0 - проверка на регистрацию
        require(userData.maxItems - getItemsCount(msg.sender) >= 1);
        
        if (users[msg.sender].refer != msg.sender) {
            users[msg.sender].refer.transfer(msg.value/10);
        }
        
        if (msg.value >= basketPrice) {
            uint _backets = msg.value/basketPrice;
            if ((userData.maxItems - getItemsCount(msg.sender)) >= _backets)
                userData.baskets += _backets;
            else
                userData.baskets += (userData.maxItems - getItemsCount(msg.sender));
        } else {
            error("Not enough ether to buy basket!", msg.sender);
        }
    }
    
    //Работает пока с багами (повторяющийся рандом + хреновая проверка на переполнение склада)
    function openBasket() external {
        user storage UserData = users[msg.sender];
        require(UserData.baskets >= 1);
        require(UserData.maxItems - getItemsCount(msg.sender) >= 4);
        
        for (uint i = 0; i < 1; i++ ) {
            bornBird(msg.sender);
            UserData.birds++;
        }
                
        //выпала амуниция
        genEquipment(msg.sender);
        UserData.equipments++;
            
        //выпала еда
        UserData.eats++;
        
        UserData.baskets--;
    }
    
    function feedBird(uint _birdId, uint _count) external {
        require(isOwnerOf(_birdId));
        require(_count > 0);
        require(getEat(msg.sender) >= _count);
        
        allBirds[_birdId].experience += _count * eatExp;
        users[msg.sender].eats -= _count;
        
        updateBirdLvl(_birdId);
    }
    
    function getUserByBirdId(uint _birdId) public constant returns (address) {
        return birdOwner[_birdId];
    }
    
    function getUserByEquipId(uint _equipId) public constant returns (address) {
        return equipOwner[_equipId];
    }
    
    function isOwnerOf(uint _bird) internal constant returns(bool){
        return birdOwner[_bird] == msg.sender;
    }
    
    function burn(uint _type) {
        if (_type == 0) {
            if (users[msg.sender].eats > 0)
                users[msg.sender].eats--;
        }
        if (_type == 1) {
            if (users[msg.sender].baskets > 0)
                users[msg.sender].baskets--;
        }
        if (_type == 2) {
            if (users[msg.sender].potions > 0)
                users[msg.sender].potions--;
        }
    }
    
    function getRefer (address _user) public constant 
    returns (address refer) {
        return users[_user].refer;    
    }
    
    event error(string msg, address owner);
}

contract Arena is User{
    uint[] waitingFightBirds;
    //uint[] winersRecovery;
    //uint[] looseRecovery;
    uint constant timeToRecover = 100;//21600;
    
    function findFighter(uint birdId) public {
        //проверка, что выставляется птица, которой он владеет
        if (getUserByBirdId(birdId) == msg.sender && !checkWaiting(birdId)){
            //поиск по уже выставленным
            bool nonWait = true;
            for (uint i=0; i<waitingFightBirds.length; i++){
                if (allBirds[waitingFightBirds[i]].level == allBirds[birdId].level){
                    fight(waitingFightBirds[i], birdId, i);
                    nonWait = false;
                }
            }
            
            //добавление в поиск
            if (nonWait) {
                waitingFightBirds.push(birdId);
            }
            
        }
    }
    
    function checkWaiting(uint birdId) public constant returns(bool) {
        bool answer = false;
        for (uint i=0; i<waitingFightBirds.length; i++){
            if (waitingFightBirds[i] == birdId)
                answer = true;
        }
        return answer;
    }
    
    function getRealHP(uint _birdId) constant returns(uint) {
        uint birdHP = getBirdHP(_birdId);
        
        if (now <= allBirds[_birdId].zeroHpTime){
            return birdHP-(allBirds[_birdId].zeroHpTime - now)*birdHP/timeToRecover;
        }
        else
            return birdHP;
    }
    
    function fight(uint firstBirdId, uint secondBirdId, uint _i) internal returns(bytes1){
        uint fbHP = getRealHP(firstBirdId);//+
        uint sbHP = getRealHP(secondBirdId);//+
        bool draw = false;
        
        //ограничить число итераций для экономии газа
        //снос HP работает не совсем корректно
        while (fbHP!=0 && sbHP!=0) {
            //wtf
            /*allBirds[firstBirdId].zeroHpTime = now;
            allBirds[secondBirdId].zeroHpTime = now;*/
            
            //first part
            uint attackFB = getAttack(firstBirdId);
                
            if (sbHP >= attackFB){
                sbHP -= attackFB;
                allBirds[secondBirdId].zeroHpTime += timeToRecover*attackFB/getBirdHP(secondBirdId);
            }
            else {
                attackFB = attackFB - sbHP;
                sbHP = 0;
                allBirds[secondBirdId].zeroHpTime = uint(now) + uint(timeToRecover);
                draw = true;
            }
            
            //second part
            uint attackSB = getAttack(secondBirdId);

            
            if (fbHP >= attackSB){
                fbHP -= attackSB;
                allBirds[firstBirdId].zeroHpTime += timeToRecover*attackSB/getBirdHP(firstBirdId);
            }
            else {
                if (draw) {
                    attackSB = attackSB - fbHP;
                    
                    if (attackFB != attackSB)
                        draw = false;
                        
                    if (attackSB > attackFB)
                        sbHP = 1;
                    if (attackSB < attackFB)
                        fbHP = 1;
                }
                else
                {
                    fbHP = 0;
                    allBirds[firstBirdId].zeroHpTime = uint(now) + uint(timeToRecover);
                }
            }
            
        }
        
        if (fbHP!=0 && sbHP==0)
            afterFirght(firstBirdId, secondBirdId, draw);
        if (fbHP==0 && sbHP!=0)
            afterFirght(secondBirdId, firstBirdId, draw);
        if (fbHP==0 && sbHP==0)
            afterFirght(firstBirdId, secondBirdId, draw);
        
        // не работает    
        delete waitingFightBirds[_i];
        message(_i);
        message(waitingFightBirds.length);
    }
    
    function getAttack(uint id) private returns(uint) {
        uint birdStrength = getBirdStrength(id);
        uint res = rand(birdStrength, birdStrength*3, now);
        fightLog(res);
        return res;
    }
    
    function afterFirght(uint winId, uint looseId, bool draw) internal {
        
        //TODO fix experience
        if (!draw) {
            allBirds[winId].win++;
            allBirds[winId].experience +=5;
            
            allBirds[looseId].lose++;
            allBirds[looseId].experience +=1;
            
        }
        else
        {
            allBirds[winId].draw++;
            allBirds[winId].experience +=3;
            
            allBirds[looseId].draw++;
            allBirds[looseId].experience +=3;
        }
        updateBirdLvl(winId);
        updateBirdLvl(looseId);
        fightResult(winId, looseId, draw);
    }
    
    event fightResult(uint, uint, bool);
    event fightLog(uint);
    event message(uint);
}

contract Admin is Arena{
    address owner;
    address moderator;
    uint constant totalStocks = 100000;
    mapping (address => uint) owners;
    uint ownerIndex;
    address[20] ownerList;
    address exchAddress;
    
    function Admin() public {
            owner = msg.sender;
            moderator = msg.sender;
            createdContract(owner);
            
            owners[owner] = totalStocks;
            
            ownerList[0] = msg.sender;
            
            
            //инициализация переменных
            userIndex = 0;
            ownerIndex = 1;
            //birdIndex = 0;
            eqIndex = 0;
            initMaxItems = 10;
            maxBaskets = 10;
            basketPrice = 1000000000000000000;
            potionPrice = 500000000000000000;
            upgrInvPrice = 500000000000000000;
            eatExp = 5;
            
            initBirdsChar();
    }
    
    function initBirdsChar() internal {
        birdsChar.push(BirdChar({
            start: 0,
            end: 17,
            hp: 10,
            strength: 1,
            strengthUpgr: 1,
            protection: 1,
            
            spec1: 20,
            spec2: 40
        }));
        
        birdsChar.push(BirdChar({
            start: 18,
            end: 35,
            hp: 8,
            strength: 2,
            strengthUpgr: 1,
            protection: 1,
            
            spec1: 15,
            spec2: 35
        }));
        
        birdsChar.push(BirdChar({
            start: 36,
            end: 53,
            hp: 12,
            strength: 1,
            strengthUpgr: 1,
            protection: 2,
            
            spec1: 15,
            spec2: 35
        }));
        
        birdsChar.push(BirdChar({
            start: 54,
            end: 71,
            hp: 9,
            strength: 1,
            strengthUpgr: 1,
            protection: 1,
            
            spec1: 15,
            spec2: 40
        }));
        
        birdsChar.push(BirdChar({
            start: 72,
            end: 89,
            hp: 10,
            strength: 2,
            strengthUpgr: 1,
            protection: 1,
            
            spec1: 13,
            spec2: 30
        }));
        
        birdsChar.push(BirdChar({
            start: 90,
            end: 107,
            hp: 8,
            strength: 3,
            strengthUpgr: 2,
            protection: 1,
            
            spec1: 13,
            spec2: 20
        }));
    }
    
    function setExchAddress(address _exchAddress) public onlyModerator {
        exchAddress = _exchAddress;
    }
    
    function birdTransfer(uint birdId, address newOwner) public {
        //проверка - запрос от биржи?
        require(msg.sender == exchAddress);
        error("fsffs", msg.sender);
        require(getItemsCount(newOwner) < users[newOwner].maxItems);

        users[birdOwner[birdId]].birds--;
        birdOwner[birdId] = newOwner;
        users[newOwner].birds++;
    } 
    
    function equipTransfer(uint equipId, address newOwner) public {
        //проверка - запрос от биржи?
        require(msg.sender == exchAddress);
        require(getItemsCount(newOwner) < users[newOwner].maxItems);

        users[equipOwner[equipId]].equipments--;
        equipOwner[equipId] = newOwner;
        users[newOwner].equipments++;
    } 
    
    function transferStocks(address _to, uint _balance) public {
        if (owners[msg.sender] >= _balance){
            owners[_to] += _balance;
            owners[msg.sender] -= _balance;
        }
        
        bool newStockHolder = true;
        
        for (uint i=0; i<ownerIndex; i++){
            if (ownerList[i] == _to){
                newStockHolder = false;
                break;
            }
        }
        
        if (newStockHolder) {
            ownerList[ownerIndex] = _to;
            ownerIndex = ownerIndex+1;
        }
    }
    
    function payDividends() public onlyStayHolder {
        if (this.balance >= 100000) {
            uint _balance = this.balance;
            for(uint i=0; i<ownerIndex; i++){
                uint summ = _balance/100000*owners[ownerList[i]];
                ownerList[i].transfer(summ);
                pay(summ, ownerList[i], owners[ownerList[i]], this.balance);
            }
        }
    }
    
    function getMyStocks() public constant onlyStayHolder returns(uint){
        return (owners[msg.sender]);
    }
    
    function setModerator(address _moderator) public onlyStayHolder {
        moderator = _moderator;
    }
    
    function getModerator() public constant returns (address) {
        return moderator;
    }
    
    // function setInitValues(uint maxItems) public onlyModerator {
    //     initMaxItems = maxItems;
    // }
    
    //Только создатель
    modifier onlyOwner()
    {
        require(msg.sender == owner);
        _;
    }
    
    //Только акционеры с акциями >= 20%
    modifier onlyStayHolder(){
        for(uint i=0; i<ownerIndex; i++){
            if (msg.sender == ownerList[i] && owners[ownerList[i]]>20000)
                _;
        }
    }
    
    //Только модератор
    modifier onlyModerator(){
        require(msg.sender == moderator);
        _;
    }
    
    event pay (uint summ, address _address, uint stosks, uint balance);
    event createdContract(address owner);
}