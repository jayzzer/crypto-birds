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
        _initBirdsChar();
    }
    
    //BirdChar[] birdsChar;
    mapping(uint=>uint256[8]) _birdsChar;
    
    function getBirdsChar(uint i) public constant returns(uint256[8] stats) {
        uint256[8] memory result;
        result = _birdsChar[i];

        return result;
    }
    
    function _initBirdsChar() private {
        _birdsChar[0] = [0,64,10,1,1,1,20,40];
        _birdsChar[1] = [65,129,8,2,1,1,15,35];
        _birdsChar[2] = [130,194,12,1,1,2,15,35];
        _birdsChar[3] = [195,259,9,1,1,1,15,40];
        _birdsChar[4] = [260,324,10,2,1,1,13,30];
        _birdsChar[5] = [325,389,8,3,2,1,13,20];
        _birdsChar[6] = [390,454,12,1,1,3,15,20];
        _birdsChar[7] = [455,519,9,3,2,1,15,25];
        _birdsChar[8] = [520,584,14,1,1,4,20,35];
        _birdsChar[9] = [585,649,14,1,1,4,20,35];
        _birdsChar[10] = [650,714,13,2,1,2,15,30];
        _birdsChar[11] = [715,779,11,3,2,2,13,15];
        _birdsChar[12] = [780,844,8,4,2,2,13,20];
        _birdsChar[13] = [845,909,12,3,2,1,13,20];
        
        _birdsChar[14] = [910,919,15,5,2,2,30,45];
        _birdsChar[15] = [920,929,16,6,3,1,30,45];
        _birdsChar[16] = [930,939,16,7,3,2,25,40];
        _birdsChar[17] = [940,949,15,5,3,3,30,40];
        _birdsChar[18] = [950,959,18,6,3,2,35,45];
        _birdsChar[19] = [960,969,12,8,4,1,40,50];
        _birdsChar[20] = [970,979,17,3,2,6,30,50];
        _birdsChar[21] = [980,989,16,3,2,7,25,45];
        
        _birdsChar[22] = [990,993,20,10,5,5,50,70];
        _birdsChar[23] = [994,997,22,12,6,6,40,70];
        _birdsChar[24] = [998,1001,24,9,4,9,60,90];
        _birdsChar[25] = [1002,1005,24,10,5,4,50,80];
        _birdsChar[26] = [1006,1009,20,8,4,10,60,80]; 
        
        _birdsChar[27] = [1010,1111,30,15,7,10,80,100];
        _birdsChar[28] = [1112,1113,28,14,7,11,80,100];
        _birdsChar[29] = [1114,1115,29,12,12,15,80,100];
    }
}