    pragma solidity > 0.7.20; 
   //pragma experimental ABIEncoderV2;
  import "./externalStorage.sol";
 
contract BloceducareCerts is ExternalStorage {
  
//events
	//Admin related events
	event AdminAdded(address _newAdmin,uint _maxAdminIndex);
	event AdminRemoved(address _newAdmin, uint _maxAdminIndex);
	event AdminLimitChanged(uint _newAdminLimit);

     //Student related events
	event StudentAdded(string msg,bytes32 _email,bytes32 _firstName,bytes32 _lastName,bytes32 _commendation);
	event StudentRemoved(string msg,bytes32 _email,uint studentIndex);
    event StudentCommendationUpdated(bytes32 _Email,bytes32 _newCommendation);
	event StudentNameUpdated(bytes32 _Email,bytes32 _newFirstName,bytes32 _newLastName);
	event StudentGradeUpdated(bytes32 _Email,Grades _newGrade);
	event StudentEmailUpdated(bytes32 _oldEmail,bytes32 _newEmail);
	event studentVerified(string msg,bytes32 addressVerified,string _msg);

    //Assignment related events
	event AssignmentAdded(bytes32 link,AssignmentStatus status,uint16 assignmentIndex);
	event AssignmentUpdated( bytes32 email, AssignmentStatus _newstatus,uint16 _assignmentIndex);

	//Certificate related events
	event certCreated(string _msg,string _name,string _with,address students,string by,address creator); 
	event certRemoved(string _msg,address _participantAddress,string _msg2,string at,uint time);

 //MODIFIERS
	modifier onlyOwner(){
		require(msg.sender == owner, "Access denied,not the owner");
		_; 
	}
	modifier onlyNewOwner(){
		require(msg.sender == newOwner, "Access denied,not a new owner");
		_; 
	}
	modifier onlyAdmins(){
	    Admin memory _admin;
	    require(admins[msg.sender].authorized == true,"Access denied,only admin");
	    _;
	}
	
	modifier onlyNonOwnerAdmins(){
          
        require(admins[msg.sender].authorized == true && msg.sender != owner ,"Access denied,only Admins that are not owner are allowed");
	    _;
	}
		modifier onlyPermissibleAdminLimit(){
		require(adminIndex <= maxAdminIndex,"The admin limit has been reached");
		_; 
	}
	modifier onlyNonExistentStudents(bytes32 _email){
	    Student memory _student;
	    _student.email = _email;
		require(_student.active == false,"Student already exist");
		_; 
	}
	modifier onlyValidStudents(bytes32 _email){
		 Student memory _student;
	    _student.email = _email;
		require(_student.active = true,"Student is not validated");
		_; 
	} 

	//CONSTRUCTOR
	constructor() public{
		owner = msg.sender;
		maxAdminIndex = 2;
		Admin memory _admin;
		grade = Grades.noGrade;
		assignment = AssignmentStatus.inactive;
		_admin.authorized = true;
		_addAdmin(owner);
		adminList.push(owner);
		adminIndex += 1;
		
	}

	//FUNCTIONS

	//transfer ownership of the contract to a given address
	  function transferOwnership(address _newOwner) public onlyOwner  {
	      _removeAdmin(owner);
	        addAdmin(_newOwner);
	         owner = _newOwner;
    }
   
	//renounce ownership of the contract
	 function renounceOwnership() public onlyOwner  returns(bool) {
	     _removeAdmin(owner); 
	     renounceOwnership();
        ownershipEnabled = false;
		return  ownershipEnabled;
    }
    //Allows owner to add an admin
	 function addAdmin(address _newAdmin) public onlyOwner{
	     Admin memory _admin;
		_admin.adminId = adminIndex;
		require(adminIndex <= maxAdminIndex,"Maximum number of admins reached");
		_addAdmin(_newAdmin);
		emit AdminAdded(_newAdmin,adminIndex);
       }
 
	   //Allows new owner to add an admin
	   function _addAdmin(address _newAdmin)  onlyOwner internal returns(bool){
	    Admin memory _admin;
	     require(admins[_newAdmin].authorized == false,"Admin already exist");
	     admins[_newAdmin] = _admin;
	     admins[_newAdmin].authorized = true;
		adminIndex += 1;
		adminList.push(_newAdmin);
		emit AdminAdded(_newAdmin,adminIndex);
       }
       
       function getAdmin() view public returns (address[] memory){
             return adminList;
     }
	   //Allow the owner to remove an Admin
	   function removeAdmin(address _adminAddress) public onlyOwner{
	       require(_adminAddress != owner,"Owner cannot be disabled");
	       delete admins[_adminAddress];
	       minus(adminIndex,1);
	       _removeAdmin(_adminAddress);
	       emit AdminRemoved( _adminAddress,adminIndex);
	   }
	    //Allow the current owner to remove an Admin
	   function _removeAdmin(address _adminAddress) internal onlyOwner{ 
		  Admin memory _admin;
		  _admin.adminId = adminIndex;
		   require(_admin.authorized == false,"Admin is not  authorised");
		   require(adminIndex > 1,"Atleast one admin is required");
		   // require(_adminAddress != owner,"owner cannot be removed");
		   delete admins[_adminAddress];
		   minus(adminIndex,1);
		   emit AdminRemoved( _adminAddress,adminIndex);
	   }
	   function changeAdminLimit(uint16 _newLimit) public  onlyOwner{
	       require(_newLimit > 1 && _newLimit > adminIndex,"New admin limit must be greater than 1 and than the previous admin count");
	       sum(maxAdminIndex,1);
	       	emit AdminLimitChanged(_newLimit);
	   }

	   //Allow an admin to add a student
          function addStudent(bytes32 _email,bytes32 _firstName,bytes32 _lastName,bytes32 _commendation,Grades _grades,AssignmentStatus _statusEnum)  onlyAdmins   
	     onlyNonExistentStudents(_email) public{
	     bytes32ToString(_firstName); 
	     bytes32ToString(_lastName);
	     bytes32ToString(_commendation);
	     Assignment memory _assignment;
	     _assignment.assignment = _statusEnum; 
             Student memory _student;
	     _student.email = _email;
	     _student.firstName = _firstName;
	     _student.lastName = _lastName;
	     _student.commendation =_commendation;
	     _student.grade = _grades;
	     _student.active == true;
	     _student.assignmentIndex = assignmentIndex; 
	     studentIndex += 1;
	     assignmentIndex = 0; 
	     studentList.push(_email);
       emit StudentAdded("New student added",_email, _firstName, _lastName, _commendation);
    } 

	//Allows Admin to update the information of a student
	function updateStudentInfo(bytes32 __email,bytes32 __firstName,bytes32 __lastName, 
	   bytes32 __commendation,AssignmentStatus __statusEnum,Grades __grade,bool __activeOrNot) public onlyAdmins  {
	     bytes32ToString(__firstName); 
	     bytes32ToString(__lastName);
	     bytes32ToString(__commendation);
	     Assignment memory _assignment;
	    _assignment.assignment = __statusEnum; 
            Student memory _student;
	    _student.email = __email;
	    _student.firstName =__firstName;
	    _student.lastName = __lastName;
	    _student.commendation =__commendation;
	    _student.grade = __grade;
	    _student.active = __activeOrNot;
	    _student.assignmentIndex = assignmentIndex; 
	    studentList.push(__email);
	}
	
      function getStudentList() view public returns (bytes32 [] memory) {
             return studentList;
     }
	//Allows Admins to disable a student
	function removeStudent(bytes32 _email)public onlyAdmins  onlyNonExistentStudents(_email){
	     Student memory _student;
	     studentsReverseMapping[ _email] = studentIndex;
             _student.active == false;
	     studentIndex -= 1;
	emit StudentRemoved("A student has just been disable",_email,studentIndex);
	}


	function changeStudentName(bytes32 _email,bytes32 _newFirstName,bytes32  _newLastName) onlyAdmins 
	onlyValidStudents(_email) public {
	     bytes32ToString(_newFirstName); 
	     bytes32ToString(_newLastName); 
	     Student memory _student;
	     _student.email = _email;
             _student.firstName = _newFirstName;
	     _student.lastName =  _newLastName;
	     emit StudentNameUpdated(_email,_newFirstName,_newLastName);
	}
	
	function changeStudentCommendation(bytes32 _email,bytes32 _newCommendation)  onlyAdmins onlyValidStudents(_email) public {
	    bytes32ToString(_newCommendation);
	    Student memory _student;
	    _student.email = _email;
            _student.commendation = _newCommendation ;
	 emit StudentCommendationUpdated(_email,_newCommendation);
	}
 
	function changeStudentGrade( bytes32 _email,Grades _newGrade) onlyAdmins onlyValidStudents(_email)public view{
	      bytes32ToString(_email); 
		Student memory _student;
		_student.email = _email;
		_student.grade =  _newGrade;
	}
	function changeStudentEmail(bytes32 _newEmail) onlyAdmins  onlyValidStudents(_newEmail) public {
	      studentsReverseMapping[_newEmail] = studentIndex;
	      bytes32ToString( _newEmail); 
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
	
      
            
      // STRING / BYTE CONVERSION
  
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
      
    function bytes32ToString(bytes32 _x) 
    public pure 
    returns (string memory result) {
        bytes memory bytesString = new bytes(32);
        uint charCount = 0;
        for (uint j = 0; j < 32; j++) {
            byte char = byte(bytes32(uint(_x) * 2 ** (8 * j)));
            if (char != 0) {
                bytesString[charCount] = char;
                charCount++;
            }
        }
        bytes memory bytesStringTrimmed = new bytes(charCount);
        for (uint j = 0; j < charCount; j++) {
            bytesStringTrimmed[j] = bytesString[j];
        }
        
        result = string(bytesStringTrimmed);
    }

 //CUSTOMISED SAFEMATH LIBRARY
    function sum(uint16 a, uint16 b) internal pure returns (uint16) {
        uint16 c = a + b;
        require(c >= a, "SafeMath: addition overflow");

        return c;
    }
    
    function minus(uint16 a, uint16 b) internal pure returns (uint16) {
        return minus(a, b, "SafeMath: subtraction overflow");
    }

    function minus(uint16 a, uint16 b, string memory errorMessage) internal pure returns (uint16) {
        require(b <= a, errorMessage);
        uint16 c = a - b;

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

    function divv(uint16 a, uint16 b) internal pure returns (uint16) {
        return divv(a, b, "SafeMath: division by zero");
    }

    function divv(uint16 a, uint16 b, string memory errorMessage) internal pure returns (uint16) {
        // Solidity only automatically asserts when dividing by 0
        require(b > 0, errorMessage);
        uint16 c = a / b;
        // assert(a == b * c + a % b); // There is no case in which this doesn't hold

        return c;
    }

    function modd(uint16 a, uint16 b) internal pure returns (uint16) {
        return modd(a, b, "SafeMath: modulo by zero");
    }

    function modd(uint16 a, uint16 b, string memory errorMessage) internal pure returns (uint16) {
        require(b != 0, errorMessage);
        return a % b;
    }


	} 
