  
pragma solidity < 0.8.12;
// SPDX-License-Identifier: MIT;

contract ExternalStorage{
	//GLOBAL STATE VARIABLES
	address  owner;
	address newOwner;
	uint16 public adminIndex; 
	uint16 public maxAdminIndex = 0;
	uint public studentIndex;
	uint16 public assignmentIndex;
	bool ownershipEnabled = true;
	bool studentExist = false;
	uint public donationTotal;
   uint public donationCount;
 


    //ENUMS
	enum Grades {noGrade,good,great,outstanding,epic,legendary}
	Grades public grade;
	
	//grades constant defaultGrade = grades.noGrade;
   

	enum AssignmentStatus{inactive,pending,completed,cancelled} 
	
	AssignmentStatus public assignment;
	

    //STRUCTS  
	//Create a data structure to reperesent each admin
	struct Admin{
		bool authorized;
		uint adminId;
	}
	address[] public adminList;
	mapping (address => Admin) admins;
    
	//Create a data structure to reperesent each assignment
	struct Assignment{
		bytes32 link;
		AssignmentStatus assignment;
		bool isFinalProject;
	}
		bytes32[] public assignmentList;
		mapping(uint16 => Assignment) assignments; //Mapping assignment Index to Assignment struct
		
		
	//Create a data structure to reperesent each student
	struct Student{
	    bytes32 email;
		bytes32 firstName;
		bytes32 lastName;
		bytes32 commendation; 
		Grades grade;
		uint16 assignmentIndex;
		bool active;
	}
		bytes32[] public studentList;
	mapping(bytes32 => Student) students;
	mapping(bytes32=> uint) studentsReverseMapping;
    //donate and withdraw mappings
     mapping(address => uint256) balances;
}


	



    


	