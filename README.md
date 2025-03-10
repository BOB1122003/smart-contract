จิรนันท์ 6521653261 week13_lab           
<h3>อธิบายโค้ด RPSLS (Rock, Paper, Scissors, Lizard, Spock) </h3>  
1. ตัวแปร
 numPlayer → นับจำนวนผู้เล่นที่เข้ามา (สูงสุด 2 คน)
 reward → จำนวน Ether ที่ใช้เป็นรางวัลสำหรับผู้ชนะ
 startTime → เวลาที่เริ่มเกม (ใช้จับเวลา)
 waitingTimeLimit → เวลาที่ผู้เล่นแรกต้องรอผู้เล่นที่สอง (120 วินาที)
 
2.โครงสร้าง
 
    mapping(address => uint) public player_choice;
    mapping(address => bool) public player_not_played;
		address[] public players;
 
 player_choice → บันทึกตัวเลือกของผู้เล่น (เช่น Rock, Paper, Scissors ฯลฯ)
 player_not_played → ใช้ติดตามว่าผู้เล่นเลือกหรือยัง
 players → เก็บที่อยู่ (address) ของผู้เล่นที่เข้าร่วม  

  commit()  ส่งค่าแฮช  
	
	  function commit(bytes32 dataHash) public {
    require(numPlayer == 2, "Game not started");
    require(commits[msg.sender].commit == bytes32(0), "Already committed");

    commits[msg.sender] = Commit(dataHash, uint64(block.number), false);
    emit CommitHash(msg.sender, dataHash, uint64(block.number));
    }
ผู้เล่นต้องส่งค่า commit ก่อน     
ค่าที่ commit เป็น bytes32 (hash ของตัวเลือกและ salt)     
ไม่สามารถ commit ซ้ำได้   

3. เวลาสำหรับการเล่น
   
       uint public numInput = 0;
       uint public timeLimit = 60; // เวลาสำหรับเลือก (60 วินาที)
       uint public revealTimeLimit = 60; // เวลาสำหรับเปิดเผยค่า (60 วินาที)

        if (numInput == 2) {
        _checkWinnerAndPay();
        }
        }
   
 numInput → จำนวนผู้เล่นที่ส่งค่ามาแล้ว
 timeLimit → จำกัดเวลาสูงสุด 60 วินาทีสำหรับเลือก
 revealTimeLimit → จำกัดเวลา 60 วินาทีสำหรับการเปิดเผยค่าหลังเลือก

4.  addPlayer() → เพิ่มผู้เล่น
   
        function addPlayer() public payable {
        require(numPlayer < 2, "Game is full");
        require(msg.value == 1 ether, "Must send exactly 1 ether");

        if (numPlayer > 0) {
        require(msg.sender != players[0], "Same player cannot join twice");
         }

        reward += msg.value;
        players.push(msg.sender);
        numPlayer++;

        if (numPlayer == 1) {
         startTime = block.timestamp; // เริ่มจับเวลารอผู้เล่นที่สอง
         } else if (numPlayer == 2) {
        startTime = block.timestamp; // รีเซ็ตเวลาเริ่มต้นเมื่อครบ 2 คน
        }
        }
  
ตรวจสอบว่า มีที่ว่างสำหรับผู้เล่นหรือไม่ (สูงสุด 2 คน)  
ผู้เล่นต้อง ส่งเงินเข้า 1 ETH เพื่อเข้าร่วม  
หากเป็นผู้เล่นที่ 2 → รีเซ็ต startTime เพื่อเริ่มเกม   


 5. ฟังก์ชัน refundIfNoOpponent() → คืนเงินหากไม่มีคู่แข่ง
    
        function refundIfNoOpponent() public {
        require(numPlayer == 1, "Cannot refund, game already started");
        require(block.timestamp > startTime + waitingTimeLimit, "Waiting time not exceeded");

        address payable player = payable(players[0]);
        player.transfer(reward);

        _resetGame();
        }
 ผู้เล่นคนแรกสามารถถอนเงินคืนได้ ถ้ารอเกิน waitingTimeLimit (120 วินาที)
 ป้องกันเงินติดค้างในสัญญา


6. ฟังก์ชัน _resetGame() → รีเซ็ตเกม
   
       function _resetGame() private {
       numPlayer = 0;
       numInput = 0;
       reward = 0;
       startTime = 0;
       delete players;
       }
 รีเซ็ตตัวแปรทั้งหมดให้กลับมาเริ่มต้นใหม่
 ทำให้เกมสามารถเริ่มรอบใหม่ได้

 Smart Contract นี้ทำอะไรได้บ้าง?
รองรับ ผู้เล่น 2 คน ในเกม Rock-Paper-Scissors-Lizard-Spock
ใช้ Ether (1 ETH ต่อคน) เป็นเงินเดิมพัน
จับเวลา 120 วินาที ถ้าผู้เล่นที่สองไม่มา → ผู้เล่นแรกขอคืนเงินได้
ป้องกันเงินติดอยู่ในสัญญาด้วย _resetGame()

<h2> อธิบายโค้ดที่ป้องกันการ lock เงินไว้ใน contract  </h2> 
 หากไม่มีระบบรีเซ็ตหรือบังคับให้ผู้เล่นต้อง reveal ภายในเวลาที่กำหนด อาจทำให้เงินค้างอยู่ในสัญญาโดยไม่มีทางถอนออกมาได้
  <code> 
 uint public timeLimit = 60; // เวลาสำหรับ commit (วินาที)  
 uint public revealTimeLimit = 60; // เวลาสำหรับ reveal (วินาที  
  </code>  
จำกัดเวลา commit และ reveal → ป้องกันเกมถูกดึงให้ยืดเยื้อ 

หากผู้เล่น commit แต่ไม่ reveal จะทำให้เกมค้างและเงินไม่สามารถถอนออกจากสัญญาได้ 
 สามารถบังคับคืนเงินเมื่อหมดเวลา (ถ้ายังไม่มีผู้ชนะ)
 
   	function forceRefund() public {
    require(numPlayer == 2, "Game not started");
    require(block.timestamp > startTime + timeLimit + revealTimeLimit, "Reveal phase still active");

    address payable account0 = payable(players[0]);
    address payable account1 = payable(players[1]);

    account0.transfer(reward / 2);
    account1.transfer(reward / 2);

    _resetGame();
    }   

หากหมดเวลายังไม่มีใคร reveal → คืนเงินให้ผู้เล่น  
ป้องกันเงินค้างอยู่ใน contract  

อธิบายโค้ดส่วนที่ทำการซ่อน choice และ commit  
Commit-Reveal Scheme เป็นเทคนิคที่ช่วยให้ผู้เล่นสามารถซ่อนค่าที่เลือก (choice) ไว้ก่อนได้ และเปิดเผยค่าจริงในภายหลัง  
โดยไม่ต้องกังวลว่าอีกฝ่ายจะรู้ค่าก่อน (ป้องกัน front-running) 

Commit  

    function commit(bytes32 dataHash) public {
    require(numPlayer == 2, "Game not started");
    require(commits[msg.sender].commit == bytes32(0), "Already committed");

    commits[msg.sender] = Commit(dataHash, uint64(block.number), false);
    }
ต้องมีผู้เล่นครบ 2 คนก่อน  
ไม่สามารถ commit ได้มากกว่าหนึ่งครั้ง  
บันทึกค่า dataHash (ที่ถูกแฮชไว้ล่วงหน้า) ลงใน mapping 

Reveal 

    function reveal(uint choice, bytes32 salt) public {
    require(numPlayer == 2, "Game not started");
    require(commits[msg.sender].revealed == false, "Already revealed");
    require(block.timestamp <= startTime + timeLimit + revealTimeLimit, "Reveal time exceeded");
    require(choice >= 0 && choice <= 4, "Invalid choice");
    require(getHash(choice, salt) == commits[msg.sender].commit, "Hash mismatch");

    commits[msg.sender].revealed = true;
    player_choice[msg.sender] = choice;
    numInput++;

    if (numInput == 2) {
        _checkWinnerAndPay();
    }
    }
ตรวจสอบว่าไม่เคย reveal มาก่อน
ตรวจสอบเวลาว่ายังอยู่ในช่วง reveal
ตรวจสอบว่า choice ที่เลือกอยู่ในช่วงที่ถูกต้อง (0 - 4)
ตรวจสอบว่าค่า commit ที่เคยส่งมาก่อนหน้านี้ตรงกับ hash ที่คำนวณใหม่หรือไม่

Commit Phase (ซ่อนค่า) 
Reveal Phase (เปิดค่า) 
ป้องกันไม่ให้ผู้เล่นเห็นค่า choice ของอีกฝ่ายก่อน 
ป้องกัน front-running จาก miner 

อธิบายโค้ดส่วนที่จัดการกับความล่าช้าที่ผู้เล่นไม่ครบทั้งสองคน
กำหนดเวลาสำหรับการเริ่มเกม 
  <code>   uint public waitingTimeLimit = 120; // จำกัดเวลารอผู้เล่นคนที่สอง 120 วินาที  </code> 

ผู้เล่นคนแรกต้องรอไม่เกิน 120 วินาที หากไม่มีคนที่สอง → ถอนเงินคืนได้ 

addPlayer() จับเวลาเมื่อมีผู้เล่นแรกเข้า
 function addPlayer() public payable {
    require(numPlayer < 2, "Game is full");
    require(msg.value == 1 ether, "Must send 1 ether");

    if (numPlayer > 0) {
        require(msg.sender != players[0], "Same player cannot join twice");
    }

    reward += msg.value;
    players.push(msg.sender);
    numPlayer++;

    if (numPlayer == 2) {
        startTime = block.timestamp; // จับเวลาเริ่มเกมเมื่อมีผู้เล่นครบ
    }
    } 

ผู้เล่นแรกเข้าเกม → ระบบบันทึก startTime 
หากผู้เล่นครบ 2 คน → เริ่มจับเวลาเกม
  ป้องกันเงินติดอยู่ใน contract → ผู้เล่นกดคืนเงินได้
  เกมไม่ค้างหากมีแค่คนเดียว → ระบบจะรีเซ็ตให้เอง



