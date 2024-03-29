	//SPDX-License-Identifier: LICENSED
	//pragma experimental ABIEncoder v2 ;
    
	pragma solidity <0.8.12 ;
	
	contract BloceducareCerts{

	//CUSTOMISED SAFEMATH LIBRARY
    function sum(uint16 a, uint16 b) internal pure returns (uint16) {
        uint16 c = a + b;
        require(c >= a, "SafeMath: addition overflow");
        return c;
    }
	function add(uint256 a, uint256 b) internal pure returns (uint256) {
       uint256 c = a + b;
         require(c >= a, "SafeMath: addition overflow");
         return c;
    }
    
    function minus(uint16 a, uint16 b) internal pure returns (uint16) {
        return minus(a, b);
    }

    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        require(b <= a);
        uint256 c = a - b;
        return c;
    }

    function mult(uint16 a, uint16 b) internal pure returns (uint16) {
        if (a == 0) {
            return 0;
        }

        uint16 c = a * b;
        require(c / a == b, "SafeMath: multiplication overflow");

        return c;
    }

    function div(uint16 a, uint16 b) internal pure returns (uint16) {
        return div(a, b);
    }

    function divv(uint16 a, uint16 b, string memory errorMessage) internal pure returns (uint16) {
        // Solidity only automatically asserts when dividing by 0
        require(b > 0, errorMessage);
        uint16 c = a / b;
        // assert(a == b * c + a % b); // There is no case in which this doesn't hold

        return c;
    }

    function mod(uint16 a, uint16 b) internal pure returns (uint16) {
        return mod(a, b);
    }

    function modd(uint16 a, uint16 b, string memory errorMessage) internal pure returns (uint16) {
        require(b != 0, errorMessage);
        return a % b;
    }


	

	//GLOBAL STATE VARIABLES
	address  owner;
	address newOwner;
	uint16 public adminIndex; 
	uint16 public maxAdminIndex = 0;
	uint public studentIndex;
	uint16 public assignmentIndex;
	bool ownershipEnabled = true;
	bool studentExist = false;
	uint public totalDonation;
   	uint public donationCount;
 


    //ENUMS
	enum Grades {noGrade,good,great,outstanding,epic,legendary}
	Grades public grade;
	
	enum AssignmentStatus{inactive,pending,completed,cancelled} 
	
	AssignmentStatus public assignment;
	

    //STRUCTS  
	// A data structure reperesenting each admin
	struct Admin{
		bool authorized;
		uint adminId;
	}

	address[] public adminList;
	mapping (address => Admin) admins;
    
	//A data structure to reperesenting each assignment
	struct Assignment{
		bytes link;
		AssignmentStatus assignment;
		bool isFinalProject;
	}
		bytes[] public assignmentList;
		mapping(uint16 => Assignment) assignments; //Mapping assignment Index to Assignment struct
		
		
	//A data structure  reperesenting each student
	struct Student{
	    bytes email;
		bytes names;
		bytes commendation; 
		Grades grade;
		uint16 assignmentIndex;
		bool active;
	}
		bytes[] public studentList;
	mapping(bytes => Student) students;
	mapping(bytes=> uint) studentsReverseMapping;
    //donate and withdraw mappings
     mapping(address => uint256) balances;


  
//events
	//Admin related events
	event AdminAdded(address _newAdmin);
	event AdminRemoved(address _Admin);
	event AdminLimitChanged(uint _newAdminLimit);

     //Student related events
	event StudentAdded(string msg,bytes _email,bytes _names,bytes _commendation);
	event StudentRemoved(string msg,bytes _email,uint studentIndex);
    event StudentCommendationUpdated(bytes _Email,bytes _newCommendation);
	event StudentNameUpdated(bytes _Email,bytes _names);
	event StudentGradeUpdated(bytes _Email,Grades _newGrade);
	event StudentEmailUpdated(bytes _oldEmail,bytes _newEmail);
	event studentVerified(string msg,bytes addressVerified,string _msg);

    //Assignment related events
	event AssignmentAdded(bytes link,AssignmentStatus status,uint16 assignmentIndex);
	event AssignmentUpdated( bytes email, AssignmentStatus _newstatus,uint16 _assignmentIndex);

	//Certificate related events
	event certCreated(string _msg,string _name,string _with,address students,string by,address creator); 
	event certRemoved(string _msg,address _participantAddress,string _msg2,string at,uint time);

	//Ownership related event
	  event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

 //MODIFIERS
	modifier onlyOwner(){
		require(msg.sender == owner, "Access denied,not the owner");
		_; 
	}
	modifier onlyNewOwner(){
		require(msg.sender == newOwner, "Access denied,not the new owner");
		_; 
	}
	modifier onlyAdmins(){
	    Admin memory _admin;
	    require(admins[msg.sender].authorized == true,"Access denied,not an authorize admin");
	    _;
	}
	
	modifier onlyNonOwnerAdmins(){   
        require(admins[msg.sender].authorized == true && msg.sender != owner ,"Access denied,caller must be an authorized admin but not the owner");
	    _;
	}
		modifier onlyPermissibleAdminLimit(){
		require(adminIndex <= maxAdminIndex,"The admin limit has been reached");
		_; 
	}
	modifier onlyNonExistentStudents(bytes memory _email){
	    Student memory _student;
	    _student.email = _email;
		require(_student.active == false,"Student already exist");
		_; 
	}
	modifier onlyValidStudents(bytes memory _email){
		 Student memory _student;
	    _student.email = _email;
		require(_student.active = true,"Student is not validated");
		_; 
	} 

	//CONSTRUCTOR
	constructor () payable  {
		owner = payable(msg.sender);
		maxAdminIndex = 2;
		adminList.push(owner);
		adminIndex += 1;
		
	}

	//FUNCTIONS

	//transfer ownership of the contract to a given address
	  function transferOwnership(address _newOwner) public onlyOwner  { 
			  require(_newOwner != address(0));
			  addAdmin(_newOwner);
        	   emit OwnershipTransferred(owner, _newOwner);
        	  owner = _newOwner;          
    }
   
	//renounce ownership of the contract
	 function renounceOwnership() public onlyOwner  returns(bool success) {
		 _removeAdmin(owner);
		 return success;	
    }
	
    //Allows owner to add an admin
	 function addAdmin(address _newAdmin) public onlyOwner{
	     Admin memory _admin;
		_admin.adminId = adminIndex;
		require(adminIndex <= maxAdminIndex,"Maximum number of admins reached");
		_admin.authorized = true;
		_addAdmin(_newAdmin);
		emit AdminAdded(_newAdmin);
       }
 
	   //Allows new owner to add an admin
	   function _addAdmin(address _newAdmin)  onlyOwner internal returns(bool success){
	    Admin memory _admin;
	     require(admins[_newAdmin].authorized == false,"Admin already exist");
		 require(adminIndex <= maxAdminIndex,"Maximum admin reached");
	     admins[_newAdmin] = _admin;
	     admins[_newAdmin].authorized = true;
		adminIndex += 1;
		adminList.push(_newAdmin);
		emit AdminAdded(_newAdmin);
		return success;
       }
       
       function getAdmin() view public returns (address[] memory){
             return adminList;
     }
	   function getOwner() viewgit public returns (address owner){
             return owner;
     }

	  function getTotalDonations() view public returns(uint) {
    return totalDonation;
  }

	  //Allow the current owner to remove an Admin
	   function _removeAdmin(address _adminAddress)   internal  onlyOwner{ 
		  Admin memory _admin;
		  _admin.adminId = adminIndex; 
		   require(adminIndex > 1,"Atleast one admin is required");
		    require(_adminAddress != owner,"owner cannot be disabled");
			 adminIndex -= 1;
            adminList[adminIndex] =  adminList[adminList.length - 1 ];
		    adminList.pop();
		    
		    emit AdminRemoved( _adminAddress);
		 
		  
	   }
	   //Allow the owner to remove an Admin
	   function removeAdmin(address _Admin) public onlyOwner{
		   _removeAdmin(_Admin);
	      
	   }
	   
	   function changeAdminLimit(uint16 _newLimit) public  onlyOwner{
	       require(_newLimit > 1 && _newLimit > adminIndex,"New admin limit must be greater than 1 and than the previous admin count");
	       sum(maxAdminIndex,1);
	       	emit AdminLimitChanged(_newLimit);
	   }

	   //Allow an admin to add a student
          function addStudent(bytes memory _email,bytes memory _names,bytes memory _commendation,Grades _grades,AssignmentStatus _statusEnum)  onlyNonOwnerAdmins   
	      public{
		 bytesToString(_email);
	     bytesToString(_names); 
	     bytesToString(_commendation);
	     Assignment memory _assignment;
	     _assignment.assignment = _statusEnum; 
             Student memory _student;
		require(_student.active == false,"Student already exist");
	     _student.email = _email;
	     _student.names = _names;
	     _student.commendation =_commendation;
	     _student.grade = _grades;
		 _assignment.assignment = _statusEnum; 
	     _student.active == true;
	     _student.assignmentIndex = assignmentIndex; 
	     studentIndex += 1;
	     assignmentIndex = 0; 
	     studentList.push(_email);
       emit StudentAdded("New student added",_email, _names, _commendation);
    } 

	//Allows Admin to update the information of a student
	function updateStudentInfo(bytes memory __email,bytes memory __names, 
	   bytes memory __commendation,AssignmentStatus __statusEnum,Grades __grade,bool __activeOrNot) public onlyAdmins  {
	     bytesToString(__names); 
	     bytesToString(__commendation);
	     Assignment memory _assignment;
	    _assignment.assignment = __statusEnum; 
            Student memory _student;
	    _student.email = __email;
	    _student.names =__names;
	    _student.commendation =__commendation;
	    _student.grade = __grade;
	    _student.active = __activeOrNot;
	    _student.assignmentIndex = assignmentIndex; 
	    studentList.push(__email);
	}
	
      function getStudentList() view public returns (bytes [] memory) {
             return studentList;
     }
	//Allows Admins to disable a student
	function removeStudent(bytes memory _email)public onlyAdmins  {
	     Student memory _student;
		 _student.email = _email;
	     studentsReverseMapping[ _email] = studentIndex;
		require(_student.active == true,"Student does not exist");
		 studentIndex -= 1;
        studentList[studentIndex] =  studentList[studentList.length - 1 ];
		studentList.pop();
		_student.active == false;
	emit StudentRemoved("A student has just been disable",_email,studentIndex);
	}


	function changeStudentName(bytes memory _email,bytes memory _newNames) onlyAdmins 
	onlyValidStudents(_email) public {
	     bytesToString(_newNames); 
	     Student memory _student;
	     _student.email = _email;
             _student.names = _newNames;
	     emit StudentNameUpdated(_email,_newNames);
	}
	
	function changeStudentCommendation(bytes memory _email,bytes memory _newCommendation)  onlyAdmins onlyValidStudents(_email) public {
	    bytesToString(_newCommendation);
	    Student memory _student;
	    _student.email = _email;
            _student.commendation = _newCommendation ;
	 emit StudentCommendationUpdated(_email,_newCommendation);
	}
 
	function changeStudentGrade( bytes memory _email,Grades _newGrade) onlyAdmins onlyValidStudents(_email)public view{
	      bytesToString(_email); 
		Student memory _student;
		_student.email = _email;
		_student.grade =  _newGrade;
	}
	function changeStudentEmail(bytes memory _newEmail) onlyAdmins  onlyValidStudents(_newEmail) public {
	      studentsReverseMapping[_newEmail] = studentIndex;
	      bytesToString( _newEmail); 
	      Student memory _student;
	      _student.email =  _newEmail;	
	}
	
	function _calcAndFetchAssignmentIndex() public pure returns(uint16){
	    bool isFinalProject;
	    Student memory studentStruct;
	    if(isFinalProject == true){
	      studentStruct.assignmentIndex = 0;
	      return  studentStruct.assignmentIndex;
	    }else{
	     sum(studentStruct.assignmentIndex,1);
	     return studentStruct.assignmentIndex;
	    }
    }

	 function donate() public payable {
    (bool success,) = owner.call{value: msg.value}("");
    require(success, "Failed to send money");
  }
	
      
            
      // STRING - BYTE CONVERSION

	 
       function stringToBytes32 (string memory _source) 
          public pure 
        returns (bytes32 result) {
        bytes memory tempEmptyStringTest = bytes(_source);
        string memory tempSource = _source;
        
        if (tempEmptyStringTest.length == 0) {
            return 0x0;
        }
        assembly{
            result := mload(add(tempSource, 32))
        }
    }
      
    // 
	function bytesToString(bytes memory byteCode)
	 public pure returns(string memory stringData)
{
    uint256 blank = 0; //blank 32 byte value
    uint256 length = byteCode.length;

    uint cycles = byteCode.length / 0x20;
    uint requiredAlloc = length;

    if (length % 0x20 > 0) //optimise copying the final part of the bytes - to avoid looping with single byte writes
    {
        cycles++;
        requiredAlloc += 0x20; //expand memory to allow end blank, so we don't smack the next stack entry
    }

    stringData = new string(requiredAlloc);

    //copy data in 32 byte blocks
    assembly {
        let cycle := 0

        for
        {
            let mc := add(stringData, 0x20) //pointer into bytes we're writing to
            let cc := add(byteCode, 0x20)   //pointer to where we're reading from
        } lt(cycle, cycles) {
            mc := add(mc, 0x20)
            cc := add(cc, 0x20)
            cycle := add(cycle, 0x01)
        } {
            mstore(mc, mload(cc))
        }
    }

    //finally blank final bytes and shrink size (part of the optimisation to avoid looping adding blank bytes1)
    if (length % 0x20 > 0)
    {
        uint offsetStart = 0x20 + length;
        assembly
        {
            let mc := add(stringData, offsetStart)
            mstore(mc, mload(add(blank, 0x20)))
            //now shrink the memory back so the returned object is the correct size
            mstore(stringData, length)
        }
    }
}
}

 
