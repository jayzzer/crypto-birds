contract stats{
    
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
    
    function stats(){
        initBirdsChar();
    }
    
    BirdChar[] birdsChar;
    
    function getBirdsChar(uint i) public constant returns(uint256[8] stats) {
        uint256[8] memory result;// = new uint256[];//(8);
        result[0] = birdsChar[i].start;
        result[1] = birdsChar[i].end;
        
        result[2] = birdsChar[i].hp;
        result[3] = birdsChar[i].strength;
        result[4] = birdsChar[i].strengthUpgr;
        result[5] = birdsChar[i].protection;
        
        result[6] = birdsChar[i].spec1;
        result[7] = birdsChar[i].spec2;
        
        return result;
    }
    
    function initBirdsChar() public {
        //Ducky
        birdsChar.push(BirdChar({
            start: 0,
            end: 64,
            hp: 10,
            strength: 1,
            strengthUpgr: 1,
            protection: 1,
            
            spec1: 20,
            spec2: 40
        }));
        
        //Cockmagic
        birdsChar.push(BirdChar({
            start: 65,
            end: 129,
            hp: 8,
            strength: 2,
            strengthUpgr: 1,
            protection: 1,
            
            spec1: 15,
            spec2: 35
        }));
        
        //Gooosle
        birdsChar.push(BirdChar({
            start: 130,
            end: 194,
            hp: 12,
            strength: 1,
            strengthUpgr: 1,
            protection: 2,
            
            spec1: 15,
            spec2: 35
        }));
        
        //Smelty Dover
        birdsChar.push(BirdChar({
            start: 195,
            end: 259,
            hp: 9,
            strength: 1,
            strengthUpgr: 1,
            protection: 1,
            
            spec1: 15,
            spec2: 40
        }));
        
        //Hammer
        birdsChar.push(BirdChar({
            start: 260,
            end: 324,
            hp: 10,
            strength: 2,
            strengthUpgr: 1,
            protection: 1,
            
            spec1: 13,
            spec2: 30
        }));
        
        //Noisy
        birdsChar.push(BirdChar({
            start: 325,
            end: 389,
            hp: 8,
            strength: 3,
            strengthUpgr: 2,
            protection: 1,
            
            spec1: 13,
            spec2: 20
        }));
        
        //Hypnocock
        birdsChar.push(BirdChar({
            start: 390,
            end: 454,
            hp: 12,
            strength: 1,
            strengthUpgr: 1,
            protection: 3,
            
            spec1: 15,
            spec2: 20
        }));
        
        //Вeadly boy
        birdsChar.push(BirdChar({
            start: 455,
            end: 519,
            hp: 9,
            strength: 3,
            strengthUpgr: 2,
            protection: 1,
            
            spec1: 15,
            spec2: 25
        }));
        
        //Fatty Daddy
        birdsChar.push(BirdChar({
            start: 520,
            end: 584,
            hp: 14,
            strength: 1,
            strengthUpgr: 1,
            protection: 4,
            
            spec1: 20,
            spec2: 35
        })); 
        
        //Miss Cuckoo
        birdsChar.push(BirdChar({
            start: 585,
            end: 649,
            hp: 14,
            strength: 1,
            strengthUpgr: 1,
            protection: 4,
            
            spec1: 20,
            spec2: 35
        }));   
        
        //Smartass
        birdsChar.push(BirdChar({
            start: 650,
            end: 714,
            hp: 13,
            strength: 2,
            strengthUpgr: 1,
            protection: 2,
            
            spec1: 15,
            spec2: 30
        }));
        
        //Blackswan
        birdsChar.push(BirdChar({
            start: 715,
            end: 779,
            hp: 11,
            strength: 3,
            strengthUpgr: 2,
            protection: 2,
            
            spec1: 13,
            spec2: 15
        }));   
        
        //Speedfork
        birdsChar.push(BirdChar({
            start: 780,
            end: 844,
            hp: 8,
            strength: 4,
            strengthUpgr: 2,
            protection: 2,
            
            spec1: 13,
            spec2: 20
        })); 
        
        //Deathfromthenest
        birdsChar.push(BirdChar({
            start: 845,
            end: 909,
            hp: 12,
            strength: 3,
            strengthUpgr: 2,
            protection: 1,
            
            spec1: 13,
            spec2: 20
        }));
        
        //Brandon Lee
        birdsChar.push(BirdChar({
            start: 910,
            end: 919,
            hp: 15,
            strength: 5,
            strengthUpgr: 2,
            protection: 2,
            
            spec1: 30,
            spec2: 45
        }));
        
        //Pinky
        birdsChar.push(BirdChar({
            start: 920,
            end: 929,
            hp: 16,
            strength: 6,
            strengthUpgr: 3,
            protection: 1,
            
            spec1: 30,
            spec2: 45
        }));
        
        //Butcher
        birdsChar.push(BirdChar({
            start: 930,
            end: 939,
            hp: 16,
            strength: 7,
            strengthUpgr: 3,
            protection: 2,
            
            spec1: 25,
            spec2: 40
        }));
        
        //Captain Sparrow
        birdsChar.push(BirdChar({
            start: 940,
            end: 949,
            hp: 15,
            strength: 5,
            strengthUpgr: 3,
            protection: 3,
            
            spec1: 30,
            spec2: 40
        }));
        
        //Great snot
        birdsChar.push(BirdChar({
            start: 950,
            end: 959,
            hp: 18,
            strength: 6,
            strengthUpgr: 3,
            protection: 2,
            
            spec1: 35,
            spec2: 45
        }));
        
        //Big Boss
        birdsChar.push(BirdChar({
            start: 960,
            end: 969,
            hp: 12,
            strength: 8,
            strengthUpgr: 4,
            protection: 1,
            
            spec1: 40,
            spec2: 50
        }));
        
        //Banana
        birdsChar.push(BirdChar({
            start: 970,
            end: 979,
            hp: 17,
            strength: 3,
            strengthUpgr: 2,
            protection: 6,
            
            spec1: 30,
            spec2: 50
        }));
        
        //Groundhead
        birdsChar.push(BirdChar({
            start: 980,
            end: 989,
            hp: 16,
            strength: 3,
            strengthUpgr: 2,
            protection: 7,
            
            spec1: 25,
            spec2: 45
        }));
        
        //Mom's pretty
        birdsChar.push(BirdChar({
            start: 990,
            end: 993,
            hp: 20,
            strength: 10,
            strengthUpgr: 5,
            protection: 5,
            
            spec1: 50,
            spec2: 70
        }));
        
        //Just toucan
        birdsChar.push(BirdChar({
            start: 994,
            end: 997,
            hp: 22,
            strength: 12,
            strengthUpgr: 6,
            protection: 6,
            
            spec1: 40,
            spec2: 70
        }));
        
        //SWAG Bird
        birdsChar.push(BirdChar({
            start: 998,
            end: 1001,
            hp: 24,
            strength: 9,
            strengthUpgr: 4,
            protection: 9,
            
            spec1: 60,
            spec2: 90
        }));
        
        //Red Bag
        birdsChar.push(BirdChar({
            start: 1002,
            end: 1005,
            hp: 24,
            strength: 10,
            strengthUpgr: 5,
            protection: 4,
            
            spec1: 50,
            spec2: 80
        }));
        
        //Loveme!
        birdsChar.push(BirdChar({
            start: 1005,
            end: 1008,
            hp: 20,
            strength: 8,
            strengthUpgr: 4,
            protection: 10,
            
            spec1: 60,
            spec2: 80
        }));
        
        //Black&White
        birdsChar.push(BirdChar({
            start: 1009,
            end: 1010,
            hp: 30,
            strength: 15,
            strengthUpgr: 7,
            protection: 10,
            
            spec1: 80,
            spec2: 100
        }));    
        
        //Rainbow
        birdsChar.push(BirdChar({
            start: 1011,
            end: 1012,
            hp: 28,
            strength: 14,
            strengthUpgr: 7,
            protection: 11,
            
            spec1: 80,
            spec2: 100
        }));
        
        //Scooter
        birdsChar.push(BirdChar({
            start: 1013,
            end: 1014,
            hp: 29,
            strength: 12,
            strengthUpgr: 12,
            protection: 15,
            
            spec1: 80,
            spec2: 100
        }));
    }
}