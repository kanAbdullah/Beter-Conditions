//SPDX-License-Identifier: MIT

//worker's weekly attendance must be renewed every week

pragma solidity ^0.8.18;

contract Company {
    
    //errors
    // interfaces, libraries, contracts
    
    // Type declarations
    enum shift{
        morning,
        evening,
        night
    }
    
    struct worker{

        uint256 workerId;
        address workerAddress;
        string name;
        uint256 age;
        uint256 salary;
        
        shift workerShift;
        bool[5] weekly_workerShiftAttendance; // 5 days of the week
        uint256 weekly_attendedShifts;
        uint256 amirId; // the amir who supervises this worker
    }

    struct amir{

        uint256 amirId;
        address amirAddress;
        string name;
        uint256 age;
        uint256 salary;

        shift amirShift;

        worker[] superVisedWorkers; // the workers supervised by this amir
    }

    // State variables
    string private companyName;
    uint256 private companyId;
    uint256 private companyRegistrationNumber;
    address private companyAddress;

    worker[] public currentlyWorkingWorkers;

    mapping(uint256 => worker) public workerId_toWorker;
    
    //this mappings can be optimized
    mapping(uint256 => amir) public amirId_toAmir;
    mapping(address => amir) public amirAddress_toAmir;
    
    // Events
    
    // Modifiers
    modifier onlyAmir(){
        require(amirAddress_toAmir[msg.sender].amirId != 0, "Only Amir can call this function");
        _;
    }
    // Functions
    constructor( 
        string memory _companyName,
        uint256 _companyId,
        uint256 _companyRegistrationNumber,
        address _companyAddress
        ) {
        companyName = _companyName;
        companyId = _companyId;
        companyRegistrationNumber = _companyRegistrationNumber;
        companyAddress = _companyAddress;
        }

    function controlWorkerAttendance(
        uint256 _workerId,
        uint256 _day,
        bool control
        ) public onlyAmir{
        workerId_toWorker[_workerId].weekly_workerShiftAttendance[_day] = control;
    }

    //an automated function that resets the weekly attendance of all workers
    function add_and_reset_WeeklyAttendance() external {
        uint256 workerAmount = currentlyWorkingWorkers.length;
        
        for(uint256 i=0; i<workerAmount ; i++){

            /*
            i've used storge because i want to 
            change the values of the workers
            that stored in state variables
            
            if i said memory, it would create a copy of the worker
            */
            worker storage w = workerId_toWorker[currentlyWorkingWorkers[i].workerId];
            
            for(uint256 j=0; j<5; j++){
                if(w.weekly_workerShiftAttendance[j] == true)
                    w.weekly_attendedShifts++;

                w.weekly_workerShiftAttendance[j] = false;
            }
        }
    }
    
    function add_Worker(worker memory _worker) public {
        workerId_toWorker[_worker.workerId] = _worker;
        currentlyWorkingWorkers.push(_worker);
    }

    function remove_Worker(uint256 _workerId) public {
        delete workerId_toWorker[_workerId];
        uint256 workerAmount = currentlyWorkingWorkers.length;

        for (uint256 i = 0; i<workerAmount ; i++){
            if(currentlyWorkingWorkers[i].workerId == _workerId){
                delete currentlyWorkingWorkers[i];
                break;
            }
        }
    }

    function add_Amir(amir memory _amir) public {
        amirId_toAmir[_amir.amirId] = _amir;
    }

    function remove_Amir(uint256 _amirId) public {
        delete amirId_toAmir[_amirId];
    }
}