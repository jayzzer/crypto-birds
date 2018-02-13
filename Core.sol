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
    uint eqIndex = 1;
    
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
    
    function bornBird (address _user, uint _type) internal returns(uint){
        Bird memory newBird;
        newBird.id = birdIndex++;
        
        //TODO fix random!!!
        if (_type == 1) {
            newBird.birdType = rand(0,108, newBird.id);
        } 
        else if (_type == 2) {
            newBird.birdType = rand(40,108, newBird.id);
        }
        else if (_type == 3) {
            newBird.birdType = rand(80,108, newBird.id);
        }
        
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
    
    function getBirdStat(uint _id) constant returns(uint win, uint loose, uint draw) {
        return (allBirds[_id].win, allBirds[_id].lose, allBirds[_id].draw);
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
    public constant 
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
    
    function getBirdSpec (uint _birdId, uint spec) public returns(uint){
        Bird storage foundBird = allBirds[_birdId];
        uint birdType = getBirdType(_birdId);
        
        if (spec == 1){
            return birdsChar[birdType-1].spec1;
        }
        if (spec == 2){
            return birdsChar[birdType-1].spec2;
        }
    }
}

contract User is BirdBase {
    uint initMaxItems;
    uint maxBaskets;
    uint egsCount;
    uint basketPriceBronze;
    uint basketPriceSilver;
    uint basketPriceGold;
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
        uint baskets_bronze;
        uint baskets_silver;
        uint baskets_gold;
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
            users[msg.sender].baskets_bronze = 0;
            users[msg.sender].baskets_silver = 0;
            users[msg.sender].baskets_gold = 0;
            users[msg.sender].potions = 0;
            
            users[msg.sender].maxItems = initMaxItems;
        }
    }
    
    function getUserBirdsID(address _user) external view returns(uint256[] ownerBirds){
        uint tokenCount;
        (tokenCount,,,,,) = getUserInventoryByAddress(_user);
        
        if (tokenCount == 0) {
            return new uint256[](0);
        } else {
            uint256[] memory result = new uint256[](tokenCount);
            uint256 resultIndex = 0;
            
            uint256 birdId;
            
            for (birdId = 0; birdId <= birdIndex; birdId++) {
                if (birdOwner[birdId] == _user) {
                    result[resultIndex] = birdId;
                    resultIndex++;
                }
            }
            
            return result;
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
    public constant 
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
            users[_user].baskets_bronze + users[_user].baskets_silver + users[_user].baskets_gold,
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
            userData.baskets_bronze + 
            userData.baskets_silver +
            userData.baskets_gold +
            userData.potions;
    }
        
    function getBuscketsCount(address _user) public constant returns(uint, uint, uint){
        return (users[_user].baskets_bronze, users[_user].baskets_silver, users[_user].baskets_gold);
    }    
        
    function getUserByID(uint _id) public constant returns (string name, string email, address _address) {
        return (users[usersId[_id]].name, users[usersId[_id]].email, usersId[_id]);
    }
    
    function getUserIndex() public constant returns (uint index){
        return userIndex;
    }
    
    function getEat(address _user) internal returns(uint){
        uint _daily = (now-users[_user].regDate)/86400;
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
    
    function buyBasket(uint _type) external payable {
        user storage userData = users[msg.sender];
        
        require(userData.maxItems > 0);//maxItems>0 - проверка на регистрацию
        require(userData.maxItems - getItemsCount(msg.sender) >= 1);
        
        uint _backets;
        
        if (_type == 1) {
            require(msg.value >= basketPriceBronze);
            
            _backets = msg.value/basketPriceBronze;
            if ((userData.maxItems - getItemsCount(msg.sender)) >= _backets)
                userData.baskets_bronze += _backets;
            else
                userData.baskets_bronze += (userData.maxItems - getItemsCount(msg.sender));
        } 
        else if (_type == 2) {
            require(msg.value >= basketPriceSilver);
            
            _backets = msg.value/basketPriceSilver;
            if ((userData.maxItems - getItemsCount(msg.sender)) >= _backets)
                userData.baskets_silver += _backets;
            else
                userData.baskets_silver += (userData.maxItems - getItemsCount(msg.sender));
        }
        else if (_type == 3) {
            require(msg.value >= basketPriceGold);
            
            _backets = msg.value/basketPriceGold;
            if ((userData.maxItems - getItemsCount(msg.sender)) >= _backets)
                userData.baskets_gold += _backets;
            else
                userData.baskets_gold += (userData.maxItems - getItemsCount(msg.sender));
        }
        
        if (users[msg.sender].refer != msg.sender) {
            users[msg.sender].refer.transfer(msg.value/10);
        }
    }
    
    //TODO 3 типа корзин
    function openBasket(uint _type) external {
        user storage UserData = users[msg.sender];
        require(UserData.maxItems - getItemsCount(msg.sender) >= 4);
        
        if (_type == 1){
            require(UserData.baskets_bronze >= egsCount);
            
            for (uint i = 0; i < egsCount; i++ ) {
                bornBird(msg.sender, _type);
                UserData.birds = UserData.birds + egsCount;
            }
            
            UserData.baskets_bronze = UserData.baskets_bronze - egsCount;
        }
        else if (_type == 2) {
            require(UserData.baskets_silver >= egsCount);
            
            for (i = 0; i < egsCount; i++ ) {
                bornBird(msg.sender, _type);
                UserData.birds = UserData.birds + egsCount;
            }
            
            UserData.baskets_silver = UserData.baskets_silver - egsCount;            
        }        
        else if (_type == 3) {
            require(UserData.baskets_gold >= egsCount);
            
            for (i = 0; i < egsCount; i++ ) {
                bornBird(msg.sender, _type);
                UserData.birds = UserData.birds + egsCount;
            }
            
            UserData.baskets_gold = UserData.baskets_gold - egsCount;             
        }
        

                
        //выпала амуниция
        genEquipment(msg.sender);
        UserData.equipments++;
            
        //выпала еда
        UserData.eats++;
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
            if (users[msg.sender].baskets_bronze > 0)
                users[msg.sender].baskets_bronze--;
        }
        if (_type == 2) {
            if (users[msg.sender].baskets_silver > 0)
                users[msg.sender].baskets_silver--;
        }
        if (_type == 3) {
            if (users[msg.sender].baskets_gold > 0)
                users[msg.sender].baskets_gold--;
        }
        if (_type == 4) {
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
    mapping (uint => uint) birdEquip;
    //uint[] winersRecovery;
    //uint[] looseRecovery;
    uint timeToRecover = 21600;
    
    function findFighter(uint birdId, uint _birdEquip) public {
        //проверка, что выставляется птица, которой он владеет
        require(getUserByBirdId(birdId) == msg.sender && !checkWaiting(birdId));
        require(_birdEquip == 0 || (getUserByEquipId(_birdEquip) == msg.sender));
            //поиск по уже выставленным
            bool nonWait = true;
            for (uint i=0; i<waitingFightBirds.length; i++){
                if (allBirds[waitingFightBirds[i]].level == allBirds[birdId].level){
                    nonWait = false;
                    uint birdOne = waitingFightBirds[i];
                    delete birdEquip[birdOne];
                    delWaiting(i);
                    fight(birdOne, birdId);
                }
            }
            
            //добавление в поиск
            if (nonWait) {
                waitingFightBirds.push(birdId);
                birdEquip[birdId] = _birdEquip;
            }
    }
    
    function delWaiting(uint i) private {
        delete waitingFightBirds[i];
        if (waitingFightBirds.length>1) {
            waitingFightBirds[i] = waitingFightBirds[waitingFightBirds.length-1];
        }
        waitingFightBirds.length--;
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
    
    function fight(uint firstBirdId, uint secondBirdId) internal returns(bytes1){
        uint fbHP = getRealHP(firstBirdId);
        uint sbHP = getRealHP(secondBirdId);
        bool draw = false;
        
        uint equipmentType1; uint equipmentType2;
        uint value1; uint value2;
        if (birdEquip[firstBirdId]!=0){
            (equipmentType1, , value1) = getEquip(birdEquip[firstBirdId]);
            if (equipmentType1 == 0)
                fbHP = fbHP + value1;
        }
        if (birdEquip[firstBirdId]!=0) {
            (equipmentType2, , value2) = getEquip(birdEquip[secondBirdId]);
            if (equipmentType2 == 0)
                sbHP = sbHP + value2;
        }
        
        while (fbHP!=0 && sbHP!=0) {
            
            //first part
            uint attackFB = getAttack(firstBirdId, birdEquip[firstBirdId]);
                
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
            uint attackSB = getAttack(secondBirdId, birdEquip[secondBirdId]);

            
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
        
        message(waitingFightBirds.length);
    }
    
    function getAttack(uint birdId, uint equipId) private returns(uint) {
        uint birdStrength = getBirdStrength(birdId);
        uint res = rand(birdStrength, birdStrength*3, now);
        uint equipmentType;
        uint value;
        uint lvl;
        if (equipId != 0) {
            (equipmentType, , value) = getEquip(equipId);
            if (equipmentType == 1)
                res = res + value;
        }
           
        (,,,lvl,,,) = getBird(birdId);
        uint ver = rand(1, 10, now);
        
        if (lvl > 10 && lvl < 21) {
            if (ver > 0 && ver < 4)
                res * getBirdSpec(birdId, 1);
        }
        if (lvl > 20) {
            if (ver > 0 && ver < 5)
                res * getBirdSpec(birdId, 2);
        }
            
        return res;
    }
    
    function afterFirght(uint winId, uint looseId, bool draw) internal {
        
        //TODO fix experience
        if (!draw) {
            allBirds[winId].win++;
            allBirds[winId].experience += getBirdHP(looseId)/11;
            
            allBirds[looseId].lose++;
            allBirds[looseId].experience += getBirdHP(winId)/44;
            
        }
        else
        {
            allBirds[winId].draw++;
            allBirds[winId].experience += getBirdHP(looseId)/25;
            
            allBirds[looseId].draw++;
            allBirds[looseId].experience += getBirdHP(winId)/25;
        }
        updateBirdLvl(winId);
        updateBirdLvl(looseId);
        fightResult(winId, looseId, draw);
    }
    
    event fightResult(uint256 win, uint256 loose, bool draw);
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
            egsCount = 1;
            basketPriceBronze = 500000000000000000;
            basketPriceSilver = 1000000000000000000;
            basketPriceGold = 2000000000000000000;
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
    
    function setBuscketPrice(uint price, uint _type) public onlyModerator {
        if (_type == 1){
            basketPriceBronze = price;
        }
        else if (_type == 2) {
            basketPriceSilver = price;
        }
        else if (_type == 3) {
            basketPriceGold = price;
        }
    }
    
    function getBuscketPrice() public constant returns(uint, uint, uint) {
        return (basketPriceBronze, basketPriceSilver, basketPriceGold);
    }
    
    function setPotionPrice(uint price) public onlyModerator {
        potionPrice = price;
    }
    
    function setInventPrice(uint price) public onlyModerator {
        upgrInvPrice = price;
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
        
    event testEvent(string mes, uint num);
    function makeEvent(string a, uint b){
        testEvent(a, b);
        fightResult(7,77,true);
    }
    
    event pay (uint summ, address _address, uint stosks, uint balance);
    event createdContract(address owner);
}