// Remix Deploy with ["0xAb8483F64d9C6d1EcF9b849Ae677dD3315835cb2", "0x4B20993Bc481177ec7E8f571ceCaE8A9e22C02db"]
pragma solidity 0.8.1;
//pragma solidity 0.7.5;
//pragma abicoder v2;


contract MultiSigWalletRequests{

/////////////////////////////////////////////
//STATE VARIABLES                          //  
/////////////////////////////////////////////


////Request object(s)

uint seq_requestId; //Handles unique id for requests

struct Request{
    //uint request_id;
    address payable requestor;
    uint approval_status; // 0=unapproved, >1 equals approved.  
    uint amount;
}

mapping (uint => Request) maprequests; 

////Approval object(s)

mapping(address => mapping(uint => bool)) mapapproved;

//Initialize approver settings

address[] oktoApprove;
uint requiredApprovalCount;


/////////////////////////////////////////////
//MODIFIERS
////////////////////////////////////////////
modifier onlyApprovers() {
    bool approver = false;
    
    //Check the approvers for a match
    for(uint i = 0;i < oktoApprove.length;i++){
     if(oktoApprove[i] == msg.sender){
         approver = true;
            }   
        }
    require(approver == true);
    _; //continue execution
    
    
}

/////////////////////////////////////////////
//FUNCTIONS
/////////////////////////////////////////////

constructor (address [] memory _Owners, uint _ReqApprovals){
    
    //Ensure we have more approvers provided than the required number of approvals.
    assert(_ReqApprovals <= _Owners.length);
    
    //Set the contract required number of signatories for full approval.
    requiredApprovalCount = _ReqApprovals;
    
    //Add the contract creator as an approver
        oktoApprove.push(msg.sender);
    
    //Create the addresses of approvers 
    for(uint i=0;i<_Owners.length;i++){
        oktoApprove.push(_Owners[i]);
        }
    
    }

function deposit() public payable{}
    //Enables the contract to be funded.

function enterRequest (uint _amount) public payable returns(Request memory) {
    //Enables the funding requests to be submitted
    
    uint myRequestId = getNewRequestId();
    Request memory myRequest = Request(payable(msg.sender),0,_amount);
    
    //Add this new request to the mapping
    maprequests[myRequestId] = myRequest;
    
    //Returns the submitted request details.
    return myRequest;
    
    }

function approveRequest(uint _reqId) public payable onlyApprovers returns(bool) {
    //set return value hook in case of transmit actions later
    bool boolTransmit = false;
    
    //Check for prior approval
         require(mapapproved[msg.sender][_reqId] == false);
    
    //Approve actions
         mapapproved[msg.sender][_reqId] = true;
         maprequests[_reqId].approval_status += 1; //update the request to +1. THIS IS WORKING
            
    //Check for all required approvals require transfer
    if(maprequests[_reqId].approval_status >= requiredApprovalCount) {
        transfer(_reqId);
        boolTransmit = true;
        }
    
    return boolTransmit;
    
    
    }

function transfer(uint _reqId) private onlyApprovers {
        //Sends the ether for a given 
        address payable sendTo = maprequests[_reqId].requestor;
        uint sendAmount = maprequests[_reqId].amount;
         
         //Send it
         sendTo.transfer(sendAmount);
    }

/////////////////////////////////////////////
//HELPER FUNCTIONS
//helper function for manging request ids
/////////////////////////////////////////////
function getNewRequestId() public returns(uint) {
    
    seq_requestId = seq_requestId + 1;
    return seq_requestId;
    
    }

/////////////////////////////////////////////
//TEST CASES
/////////////////////////////////////////////
function testContractBal(address _contractAddy) public view returns(uint){
    
    return _contractAddy.balance;
}

function testmodifersList() public view returns(bool) {
    //Test Case: Checks if the current address is an meets modifier for approver
    bool approver = false;
    
    //Check the approvers for a match
    for(uint i = 0;i < oktoApprove.length;i++){
     if(oktoApprove[i] == msg.sender){
         approver = true;
            }   
        }
    return approver;   
}

function testTransferReqMap(uint _reqId) public view returns(bool){
    //Test Case: Checks if current address has approved or not
    return mapapproved[msg.sender][_reqId];   
    }

function testApproversConstructor() public view returns(address [] memory){
    //Test Case: Allows verifying the approvers input at deployment of the contract are correct.
    return oktoApprove;
    }

function testRequestQ(uint _reqId) public view returns(Request memory){
    
    return maprequests[_reqId];
    }

function testCheckLastRequestId() public view returns(uint){
    
    return seq_requestId;
    }

function testRequiredAppCount() public view returns(uint){
    
    return requiredApprovalCount;
    }

function testReqAddress(uint _reqId) public view returns(address){
    
    return maprequests[_reqId].requestor;
    }

}