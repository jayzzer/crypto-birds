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

contract CoolDown{
    /* Пример для таймера */
    uint start_time;
    uint totalBirds;
    
    //TODO onlyStayHolder && moderator
    function startCoolDown() public {
        totalBirds = 0;
        start_time = now;
    }
    
    function calcTime() private {
        uint newbirds = (now-start_time)/3;
        totalBirds += newbirds;
    }
    
    function getTotalBirds() constant returns (uint _birds){
        calcTime();
        return totalBirds;
    }
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
        
        uint totalHP;
        uint zeroHpTime;
        
        uint win;
        uint lose;
        uint draw;
        
        uint strength;
        uint protection;
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
        
        initBirdChar(newBird.id);
        
        return newBird.id;
    }
    
    function initBirdChar(uint _birdId) internal {
        Bird storage foundBird = allBirds[_birdId];
        
        for (uint i=0; i < birdsChar.length; i++) {
            if (foundBird.birdType >= birdsChar[i].start && foundBird.birdType <= birdsChar[i].end) {
                foundBird.totalHP = birdsChar[i].hp;
                foundBird.strength = birdsChar[i].strength;
                foundBird.protection = birdsChar[i].protection;
                
                break;
            }
        }
    }
    
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
    
    function getEquipValue(uint lvl) internal constant returns(uint) {
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
        return (birdOwner[_id], allBirds[_id].id, allBirds[_id].birdType, allBirds[_id].level, allBirds[_id].experience,allBirds[_id].totalHP, allBirds[_id].win/*,allBirds[_id].lose,allBirds[_id].strength,allBirds[_id].protection*/);
    }
    
    //Возможна ошибка при "перескоке через уровень"
    function updateBirdLvl(uint _birdId) internal {
        Bird storage foundBird = allBirds[_birdId];
        
        for (uint i = foundBird.level; i < lvlTable.length; i++) {
            if (foundBird.experience >= lvlTable[i] && foundBird.experience < lvlTable[i+1]) {
                foundBird.level = i+1;
                updateBirdChar(_birdId);
            }
        }
        
        birdLvlUp(foundBird.level);
    }
    
    function updateBirdChar(uint _birdId) internal {
        Bird storage foundBird = allBirds[_birdId];
        
        for (uint i=0; i < birdsChar.length; i++) {
            if (foundBird.birdType >= birdsChar[i].start && foundBird.birdType <= birdsChar[i].end) {
                foundBird.totalHP += birdsChar[i].hp;
                foundBird.strength += birdsChar[i].strengthUpgr;
                foundBird.protection += birdsChar[i].protection;
                
                break;
            }
        }
    }
    
}

contract User is BirdBase{    
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
        uint[] birds;
        uint[] equipments;
        uint eats;
        uint baskets;
        uint potions;
        uint regDate;
        
        uint maxItems;
        uint itemsCount;
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
            users[msg.sender].itemsCount = 0;
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
        return (users[_user].birds.length,
            users[_user].equipments.length,
            getEat(_user),
            users[_user].baskets,
            users[_user].potions,
            
            users[_user].maxItems,
            users[_user].itemsCount
        );
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
        
        if (users[_user].maxItems >= (users[_user].itemsCount + _daily))
            users[_user].eats = _daily + users[_user].eats;
        else
            users[_user].eats = users[_user].eats + users[_user].maxItems - users[_user].itemsCount;
            
        updateItemsCount(_user);
        return users[_user].eats;
    }
    
    function upgradeInventory () external payable {
        user storage userData = users[msg.sender];
        require(userData.maxItems > 0);//maxItems>0 - проверка на регистрацию
        require(userData.maxItems < 30); //Ограничение на расширение(если вдруг нужно)
        require(msg.value == upgrInvPrice);
        
        userData.maxItems += 5;
    }
    
    function updateItemsCount (address _sender) internal returns (uint itemsCount){
        user storage userData = users[_sender];
        
        userData.itemsCount = //userData.birds.length + 
            userData.equipments.length + 
            userData.eats + 
            userData.baskets + 
            userData.potions;
            
        return userData.itemsCount;
    }
    
    function buyPotion() external payable {
        user storage userData = users[msg.sender];
        require(userData.maxItems > 0);//maxItems>0 - проверка на регистрацию
        require(userData.maxItems - userData.itemsCount >= 1);
        require(msg.value >= potionPrice);
        
        if (users[msg.sender].refer != msg.sender) {
            users[msg.sender].refer.transfer(msg.value/10);
        }
        
        uint _potions = msg.value/potionPrice;
        if ((userData.maxItems - userData.itemsCount) >= _potions)
            userData.potions += _potions;
        else
            userData.potions += (userData.maxItems - userData.itemsCount);
            
        updateItemsCount(msg.sender);
    }
    
    function buyBasket() external payable {
        user storage userData = users[msg.sender];
        require(userData.maxItems > 0);//maxItems>0 - проверка на регистрацию
        require(userData.maxItems - userData.itemsCount >= 1);
        
        if (users[msg.sender].refer != msg.sender) {
            users[msg.sender].refer.transfer(msg.value/10);
        }
        
        if (msg.value >= basketPrice) {
            uint _backets = msg.value/basketPrice;
            if ((userData.maxItems - userData.itemsCount) >= _backets)
                userData.baskets += _backets;
            else
                userData.baskets += (userData.maxItems - userData.itemsCount);
                
            updateItemsCount(msg.sender);
        } else {
            error("Not enough ether to buy basket!", msg.sender);
        }
    }
    
    //Работает пока с багами (повторяющийся рандом + хреновая проверка на переполнение склада)
    function openBasket() external {
        user storage UserData = users[msg.sender];
        require(UserData.baskets >= 1);
        require(UserData.maxItems - UserData.itemsCount >= 4);
        
        for (uint i = 0; i < 1; i++ ) {
            UserData.birds.push(bornBird(msg.sender));
        }
                
        //выпала амуниция
        UserData.equipments.push(genEquipment(msg.sender));
            
        //выпала еда
        UserData.eats++;
        
        UserData.baskets--;
            
        updateItemsCount(msg.sender);
    }
    
    function feedBird(uint _birdId, uint _count) external {
        require(isOwnerOf(_birdId));
        require(_count > 0);
        require(getEat(msg.sender) >= _count);
        
        allBirds[_birdId].experience += _count * eatExp;
        users[msg.sender].eats -= _count;
        
        updateItemsCount(msg.sender);
        updateBirdLvl(_birdId);
    }
    
    function getUserByBirdId(uint _birdId) public constant returns (address) {
        return birdOwner[_birdId];
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
    
    
    
    event error(string msg, address owner);
}

contract Arena is User, CoolDown{
    uint[] waitingFightBirds;
    uint[] winersRecovery;
    uint[] looseRecovery;
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
        if (now <= allBirds[_birdId].zeroHpTime){
            return allBirds[_birdId].totalHP-(allBirds[_birdId].zeroHpTime - now)*allBirds[_birdId].totalHP/timeToRecover;
        }
        else
            return allBirds[_birdId].totalHP;
    }
    
    function fight(uint firstBirdId, uint secondBirdId, uint _i) internal returns(bytes1){
        uint fbHP = getRealHP(firstBirdId);
        uint sbHP = getRealHP(secondBirdId);
        bool draw = false;
        
        //ограничить число итераций для экономии газа
        //переделать принцип работы с защитой
        //снос HP работает не совсем корректно
        while (fbHP!=0 && sbHP!=0) {
            allBirds[firstBirdId].zeroHpTime = now;
            allBirds[secondBirdId].zeroHpTime = now;
            
            //first part
            uint result1;
            uint attackFB = getAttack(firstBirdId);
            uint protectionSB = getProtection(secondBirdId);
            
            if (attackFB > protectionSB)
                result1 = attackFB-protectionSB;
            else 
                result1 = 0;
                
            if (sbHP >= result1){
                sbHP -= result1;
                allBirds[secondBirdId].zeroHpTime += timeToRecover*result1/allBirds[firstBirdId].totalHP;
            }
            else {
                result1 = result1 - sbHP;
                sbHP = 0;
                allBirds[secondBirdId].zeroHpTime = uint(now) + uint(timeToRecover);
                draw = true;
            }
            
            //second part
            
            uint result2;
            uint attackSB = getAttack(secondBirdId);
            uint protectionFB = getProtection(firstBirdId);

            if (attackSB > protectionFB)
                result2 = attackSB-protectionFB;
            else 
                result2 = 0;
            
            if (fbHP >= result2){
                fbHP -= result2;
                allBirds[firstBirdId].zeroHpTime += timeToRecover*result2/allBirds[firstBirdId].totalHP;
            }
            else {
                if (draw) {
                    result2 = result2 - fbHP;
                    
                    if (result1 != result2)
                        draw = false;
                        
                    if (result2 > result1)
                        sbHP = 1;
                    if (result2 < result1)
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
    }
    
    function getAttack(uint id) private returns(uint) {
        uint res = rand(allBirds[id].strength, allBirds[id].strength*3, now);
        fightLog(res);
        return res;
    }
    
    function getProtection(uint id) private returns(uint) {
        uint res = rand(0, allBirds[id].protection*2, now);
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
            
            startCoolDown();
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
        require(users[newOwner].itemsCount < users[newOwner].maxItems);

        birdOwner[birdId] = newOwner;
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