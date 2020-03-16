pragma solidity >=0.4.21 <0.7.0;
    contract Isettle{
        //state variables
        address owner;
        address[] public adminsList;
        uint[] public lawyersList; 
        address[] public  expertsList;
        bytes32[] public claimantsList;
        bytes32[] public respondentsList;
        address[] public caseList;
        address[] public inmateList;
        uint16 public adminIndex;
        uint public caseCount;
        uint public claimantsIndex;   
        uint public  lawyersIndex;
        uint public expertsIndex;
        uint public respondentsIndex;
        uint public inmateCount;
        uint public donationTotal;
        uint public donationCount;

        struct Admin{
        address adminId;
        bool isAdmin;
	    }

        struct Lawyers{
        address lawyersId;
        bytes32 fullName;
        bytes32 email;
        uint phoneNumber;
        bytes32 speciality;
        uint supremeCourtNo;
        bool isLawyer; 
        address caseId;
        string resolution;
	    }

        struct  Experts{
        address expertsId;
        bytes32 fullName;
        bytes32 email;
        uint phoneNumber;
        bytes32 speciality;
        bool isExpert; 
        address caseId;
        string analysis;
	    }

       struct Case{
        address caseId;
        string complaints;//complainants agitation
        string response; //defendants response
        bytes32 settlement;//The lawyers(s) settlement 
        bytes32 caseSpeciality;
        string analysis;
        bool isSettled;//To know if a case is settled or not
        bool caseExist;//To know if a case already exist or no
	    }
	
        struct Complainants{
        address complainantsId;
        bytes32 fullName;
        bytes32 email;
        uint phoneNumber;
        bytes32 expertise;
        address caseId;
        string complaints;
	    }
        struct Respondents{
        address respondentsId;
        bytes32 fullName;
        uint phoneNumber;
        bytes32 email;
        bytes32 expertise;
        address caseId;
        string response;
	    }

        struct Inmates{
        address inmateId;    
        bytes32 fullName;
        bytes32  homeAddress;
        bytes32 inmateNumber;
        uint  bailFee;
        bool exist;
        bool isFreed;
        }

        enum caseStatus {pending,ongoing,defaulted,settled}
	    caseStatus public casestatus;

        mapping (address =>Lawyers)public lawyersmap;
        mapping(address =>Experts)public expertsmap;
        mapping(address =>Case) public casesmap;
        mapping(address =>Complainants) public complainantsmap;
        mapping(address =>Respondents) public respondentsmap;
        mapping(address => Admin) public adminsmap;
        mapping(address => uint256) balances;

                        //MODIFIERS
        modifier onlyOwner(){
		    require(msg.sender == owner, "Access denied,not the owner");
		    _; 
	    }

        modifier onlyAdmins{
	        require(adminsmap[msg.sender].isAdmin,"Access denied,only admin");
	        _;
	    }

        modifier onlyExperts(){
	        require(expertsmap[msg.sender].isExpert,"Access denied,only expert");
	        _;
	    }
	
	    modifier onlyLawyers(){
	        require(lawyersmap[msg.sender].isLawyer,"Access denied,only lawyer");
	        _;
	    }
                         //EVENTS
        event AdminAdded(address newAdmin,uint indexed adminIndex);
        event lawyersAdded(string  msg,bytes32 indexed fullName,bytes32 speciality,uint _supremeCourtNo);
        event expertsAdded(string msg,bytes32 indexed fullName,bytes32 speciality);
    
        event AdminRemoved(address admin,uint indexed adminIndex);
        event LawyerRemoved(address lawyerAddress,uint indexed lawyersIndex);
        event ExpertRemoved(address expertAddress,uint indexed lawyersIndex);
        
        event ComplainantAdded(string msg,address _complainantsId,bytes32 _fullName,bytes32 _email,uint _phoneNumber);
     
        event CaseAdded(string msg,address  indexed caseId,bytes32 caseSpeciality,string  complaints);
        event ResponseAdded(string msg,address indexed  caseId,bytes32 caseSpeciality,string  _response);
        event CaseAnalysisAdded(string msg,address indexed  caseId,bytes32 caseSpeciality,string analysis );
        event CaseResolutionAdded(string msg,address indexed  caseId,bytes32 caseSpeciality,string response);
        event NewInmateAdded(string msg,address _inmateId, bytes32 _fullName,bytes32 _homeAddress,bytes32 _inmateNumber,uint _bailFee);
        
         event DonationAdded(string msg,uint _donation);
         event WithdrawalExecuted(string msg,uint _donation);
     
                           //CONSTRUCTOR
	    constructor() public{
		    owner = msg.sender;
            addAdmin(owner);
		    casestatus = caseStatus.pending;
	    }
         //FUNCTIONS
        //Allows owner to add an admin
	    function addAdmin(address _newAdmin) public onlyOwner{
	        Admin memory _admin;
		    require(adminsmap[_newAdmin].isAdmin == false,"Admin already exist");
		    adminsmap[_newAdmin] = _admin;
		    adminsmap[_newAdmin].isAdmin = true;
		    adminIndex += 1;
		    adminsList.push(_newAdmin);
		    emit AdminAdded(_newAdmin,adminIndex);
        } 
       
       //Allows admins to add lawyers
        function addLawyer(address _lawyersId,bytes32  _fullName,bytes32 _email,uint _phoneNumber,bytes32 _speciality,uint _supremeCourtNo)public onlyAdmins {
            Experts memory _expertStruct;
            Lawyers memory _lawyerStruct;
            require(_expertStruct.isExpert == false,"Already registered as an expert");
            require(_lawyerStruct.isLawyer == false,"Already registered as a lawyer");
            require(adminsmap[_lawyersId].isAdmin == false,"Address already exist as an admin");
            _lawyerStruct.lawyersId =_lawyersId;
            _lawyerStruct.email =_email;
            _lawyerStruct.phoneNumber = _phoneNumber;
            _lawyerStruct.fullName =_fullName;
            _lawyerStruct.speciality =_speciality;
            _lawyerStruct.supremeCourtNo =_supremeCourtNo;
            caseCount = 0;
            lawyersIndex += 1;
		    lawyersList.push(_supremeCourtNo);
            emit lawyersAdded("New lawyer added:",_fullName,_speciality,_supremeCourtNo);
        }
             //Allows admin to add  experts
        function addExpert(address _expertsId,bytes32 _fullName,bytes32 _email,uint _phoneNumber,bytes32 _speciality)public onlyAdmins {
            Lawyers memory _lawyerStruct;
            Experts memory _expertStruct;
            require(adminsmap[_expertsId].isAdmin == false,"Address already exist as an admin");
            require(_expertStruct.isExpert == false,"Expert already exist");
            require(_lawyerStruct.isLawyer == false,"Already registered as a lawyer");
            _expertStruct.expertsId =  _expertsId;
            _expertStruct.fullName =_fullName;
            _expertStruct.phoneNumber =_phoneNumber;
            _expertStruct.email =_email;
            _expertStruct.speciality =_speciality;
            caseCount = 0;
            expertsIndex += 1;
            emit expertsAdded("New expert added:",_fullName,_speciality);        
}
        function addComplainant(address _complainantsId,bytes32 _fullName,bytes32 _email,uint _phoneNumber)public onlyAdmins {
            //Case memory caseStruct;
            require(adminsmap[_complainantsId].isAdmin == false,"Address already exist as an admin");
            Complainants memory complainantStruct;
            complainantStruct.complainantsId =_complainantsId;
            complainantStruct.fullName =_fullName;
            complainantStruct.email =_email;
            complainantStruct.phoneNumber =_phoneNumber;
            claimantsIndex += 1;
		    claimantsList.push(_fullName);
           emit ComplainantAdded("New lawyer added:",_complainantsId,_fullName,_email,_phoneNumber);
           }

        function addRespondents(address _respondentsId,bytes32 _fullName,uint _phoneNumber, bytes32 _email)public onlyAdmins {
            Respondents memory respondentStruct;
            respondentStruct.respondentsId =_respondentsId;
            respondentStruct.fullName =_fullName;
            respondentStruct.email =_email;
            respondentStruct.phoneNumber =_phoneNumber;
            respondentsIndex += 1;
		    respondentsList.push(_email);
            //emit respondentsAdded("New lawyer added:",_fullName,_speciality,_supremeCourtNo);
        }
        
         //Allow the current owner to remove an Admin
	    function removeAdmin(address _adminAddress) public onlyOwner{ 
		   	require(adminsmap[_adminAddress].isAdmin == true,"Sorry,address is not an admin");
			require(adminIndex > 1,"Atleast one admin is required");
			require(_adminAddress != owner,"owner cannot be removed");
			delete adminsmap[_adminAddress];
			adminIndex -= 1;
			emit AdminRemoved( _adminAddress,adminIndex);
	    } 
        
        function removeLawyer(address _lawyerAddress) public onlyOwner{ 
		   	require(lawyersmap[_lawyerAddress].isLawyer == true,"Sorry,address is not a lawyer");
			require(lawyersIndex > 1,"Atleast one lawyer is required");
			require(_lawyerAddress != owner,"owner cannot be removed");
			delete lawyersmap[_lawyerAddress];
			adminIndex -= 1;
			emit LawyerRemoved( _lawyerAddress,lawyersIndex);
	    } 
	   
	    function removeExpert(address _expertAddress) public onlyOwner{ 
		   	require(expertsmap[_expertAddress].isExpert == true,"Sorry,address is not an expert");
			require(expertsIndex > 1,"Atleast one expert is required");
			require(_expertAddress != owner,"owner cannot be removed");
			delete expertsmap[_expertAddress];
		    adminIndex -= 1;
		    emit ExpertRemoved( _expertAddress,expertsIndex);
	    } 
	   
	    function lodgeComplaint(address _caseId,bytes32 _caseSpeciality,string memory _complaint)public {
            Case memory _caseStruct;
            require(_caseStruct.caseExist == false,"Case already exist");
            require(_caseStruct.isSettled == false,"Case has been settled by a lawyer");
            require(casesmap[_caseId].caseExist == false,"Case already exist");
            _caseStruct.caseId = _caseId;
            _caseStruct.caseSpeciality =_caseSpeciality;
            caseCount += 1;
		    caseList.push(_caseId);
            emit CaseAdded("New case added:",_caseId,_caseSpeciality,_complaint);
        }

	    function respondToComplaint(address _caseId,bytes32 _caseSpeciality,string memory _response)public {
            Case memory _caseStruct;
            require(_caseStruct.caseExist == true,"Case does not exist");
            require(_caseStruct.isSettled == false,"Case has been settled by a lawyer");
            _caseStruct.caseId = _caseId;
            _caseStruct.caseSpeciality =_caseSpeciality;
            caseCount += 1;
		    caseList.push(_caseId);
            emit ResponseAdded("New response added:",_caseId,_caseSpeciality,_response);
        }


	    function analyseCase(address _caseId,bytes32 _caseSpeciality,string memory _analysis)public onlyExperts {
            Case memory _caseStruct;
            require(_caseStruct.caseExist == false,"Case already exist");
            require(_caseStruct.isSettled == false,"Case has been settled by a lawyer");
            require(casesmap[_caseId].caseExist == false,"Case already exist");
            _caseStruct.caseId = _caseId;
            _caseStruct.caseSpeciality =_caseSpeciality;
            _caseStruct.analysis =_analysis;
            caseCount += 1;
		    caseList.push(_caseId);
            emit CaseAnalysisAdded("New case analysis added:",_caseId,_caseSpeciality,_analysis);
        }


	    function resolveDispute(address _caseId,bytes32 _caseSpeciality,string memory _resolution)public onlyLawyers {
            Case memory _caseStruct;
            require(_caseStruct.caseExist == false,"Case already exist");
            require(_caseStruct.isSettled == false,"Case has been settled by a lawyer");
            require(casesmap[_caseId].caseExist == false,"Case already exist");
            _caseStruct.caseId = _caseId;
            _caseStruct.caseSpeciality =_caseSpeciality;
            caseCount += 1;
		    caseList.push(_caseId);
            emit CaseResolutionAdded("New case resolution added:",_caseId,_caseSpeciality,_resolution);
        }

        function addInmate(address _inmateId,bytes32 _fullName,bytes32 _homeAddress,bytes32 _inmateNumber,uint _bailFee)public {
            Inmates memory inmateStruct;
            require(inmateStruct.exist == false,"inmate already exist");
            inmateStruct.inmateId = _inmateId;
            inmateStruct.fullName =_fullName;
            inmateStruct.homeAddress =_homeAddress;
            inmateStruct.inmateNumber =_inmateNumber;
            inmateStruct.bailFee =_bailFee;
            inmateCount += 1;
		    inmateList.push(_inmateId);
            emit NewInmateAdded("New inmate added:",_inmateId,_fullName,_homeAddress,_inmateNumber,_bailFee);      
        }

        function  donateEth(uint _donation) public payable {
            balances[msg.sender] -=  _donation;
            donationTotal +=  _donation; 
            donationCount += 1;
            require(_donation >= 5000000000000000,"Below minimum donation");
            emit DonationAdded("New donation added",_donation);
        }

        function withdraw(uint _withdrawal)  public payable onlyOwner{
        balances[msg.sender] +=  _withdrawal;
        donationTotal -=  _withdrawal; 
        require(msg.sender.send(donationTotal));
       emit WithdrawalExecuted("New donation added",_withdrawal);
       }
   
      // STRING / BYTE CONVERSION
  
       function stringToBytes32(string memory _source) 
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