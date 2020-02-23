
pragma solidity <0.6.20;

contract ExternalStorage{
	//GLOBAL STATE VARIABLES
	address  owner;
	address newOwner;
	uint16  adminIndex; 
	uint16 maxAdminIndex = 2;
	uint studentIndex;
	uint16 assignmentIndex;
	bool ownershipEnabled = true;
	bool certificateExist = false;
	uint certificateIndex;


    //ENUMS
	enum grades {noGrade,good,great,outstanding,epic,legendary}
	grades grade;
	//grades constant defaultGrade = grades.noGrade;
   

	enum assignmentStatus{inactive,pending,completed,cancelled}  
	assignmentStatus assignment;
	//assignments constant defaultAssignment = assignments.inactive;
	// assignment = assignments.COMPLETED;

    //STRUCTS  
	//Create a data structure to reperesent each admin
	struct Admin{
		bool authorized;
		uint id;
	}
	//Create a data structure to reperesent each assignment
	struct Assignment{
		string link;
		assignmentStatus status;
	}
	//Create a data structure to reperesent each student
	struct Student{
	    uint studentId;
	    string email;
		string firstName;
		string lastName;
		string commendation; 
		grades grade;
		assignmentStatus assignment;
		bool active;
		 
	}
	// Create a data structure to reperesent each certificate
	struct Certificate{
	uint certificateId;
	address studentAddress; 
	string email;
	string firstName;
	string lastName;
	string commendation;
	grades grade;
	assignmentStatus assignment;
	uint assignmentIndex;
	} 

//Arrays of certificates,admins,students,and assignments
	string[] certificateList;
	address[] adminList;
	string[] studentList;
	string[] assignmentList;


	//mapping
	mapping(address => Certificate) public certificates;
	mapping(string => bool) private isParticipant;
	mapping (address => bool) admins;
    mapping(address =>Admin)adminReverseMapping;
	mapping(address => Student) students;
	mapping(string => uint) studentsReverseMapping;
	mapping(uint => Assignment) assignments;
}
    


	