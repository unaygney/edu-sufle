// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract Sufle {

    address public owner;
    
    struct Survey {
        uint256 surveyId;
        address userAddress;
        string occupation;
        string[] interestedCategories;
        string[] motivations;
        string lifeGoals;
        uint256 createdAt;
    }

    struct Path {
        uint256 pathId;
        string title;
        string description;
        mapping(uint256 => Task) tasks;
    }
    
    struct Task {
        uint256 taskId;
        string title;
        string description;
        string priority;
        string status;
        string tags;
    }

    mapping(uint256 => Task) public tasks;
    mapping(uint256 => Path) public paths;
    mapping(uint256 => Survey) public surveys;
    mapping(address => uint256[]) public userSurveys;

    event TaskCreated(uint256 taskId, string title, string description, string priority, string status, string tags);
    event PathCreated(uint256 pathId, string title, string description);
    event GeneratedPath(uint256 pathId, string title, string description);
    event SurveyCreated(uint256 surveyId, address indexed userAddress);
    event SurveyUpdated(uint256 surveyId, address indexed userAddress);

    constructor() {
        owner = msg.sender;
    }

    modifier onlyOwner() {
        require(msg.sender == owner, "Only the owner can call this function");
        _;
    }

    function createTask(string memory _title, string memory _description, string memory _priority, string memory _status, string memory _tags) public onlyOwner {
        uint256 taskId = uint256(keccak256(abi.encodePacked(_title, _description, block.timestamp))); 
        tasks[taskId] = Task(taskId, _title, _description, _priority, _status, _tags);
        emit TaskCreated(taskId, _title, _description, _priority, _status, _tags); 
    }
    
    function createPath(string memory _title, string memory _description, uint256[] memory _taskIds) public onlyOwner {
        uint256 pathId = uint256(keccak256(abi.encodePacked(_title, _description, block.timestamp)));
        Path storage newPath = paths[pathId];
        newPath.pathId = pathId;
        newPath.title = _title;
        newPath.description = _description;

        for (uint256 i = 0; i < _taskIds.length; i++) {
            newPath.tasks[_taskIds[i]] = tasks[_taskIds[i]];
        }

        emit PathCreated(pathId, _title, _description);
    }

    function getPathInfo(uint256 _pathId) public view returns (uint256, string memory, string memory) {
        Path storage path = paths[_pathId];
        return (path.pathId, path.title, path.description);
    }
    
    function getPathTask(uint256 _pathId, uint256 _taskId) public view returns (uint256, string memory, string memory, string memory, string memory, string memory) {
        Task storage task = paths[_pathId].tasks[_taskId];
        return (task.taskId, task.title, task.description, task.priority, task.status, task.tags);
    }

    function getTaskInfo(uint256 _taskId) public view returns (uint256, string memory, string memory, string memory, string memory, string memory) {
        Task storage task = tasks[_taskId];
        return (task.taskId, task.title, task.description, task.priority, task.status, task.tags);
    }

    function generatePathWithAI(uint256 _id) public payable {
        require(msg.value >= 0.01 ether, "You must pay at least 0.01 ether");
        require(paths[_id].pathId != 0, "Path does not exist");

        emit GeneratedPath(_id, paths[_id].title, paths[_id].description);
        
    }

    function createUserSurvey(
        string memory _occupation, 
        string[] memory _interestedCategories, 
        string[] memory _motivations, 
        string memory _lifeGoals
    ) public {
        uint256 surveyId = uint256(keccak256(abi.encodePacked(msg.sender, block.timestamp)));
        Survey storage newSurvey = surveys[surveyId];
        newSurvey.surveyId = surveyId;
        newSurvey.userAddress = msg.sender;
        newSurvey.occupation = _occupation;
        newSurvey.interestedCategories = _interestedCategories;
        newSurvey.motivations = _motivations;
        newSurvey.lifeGoals = _lifeGoals;
        newSurvey.createdAt = block.timestamp;
        
        userSurveys[msg.sender].push(surveyId);
        
        emit SurveyCreated(surveyId, msg.sender);
    }
    
    function createSurveyForUser(
        address _userAddress,
        string memory _occupation, 
        string[] memory _interestedCategories, 
        string[] memory _motivations, 
        string memory _lifeGoals
    ) public onlyOwner {
        uint256 surveyId = uint256(keccak256(abi.encodePacked(_userAddress, block.timestamp)));
        Survey storage newSurvey = surveys[surveyId];
        newSurvey.surveyId = surveyId;
        newSurvey.userAddress = _userAddress;
        newSurvey.occupation = _occupation;
        newSurvey.interestedCategories = _interestedCategories;
        newSurvey.motivations = _motivations;
        newSurvey.lifeGoals = _lifeGoals;
        newSurvey.createdAt = block.timestamp;
        
        userSurveys[_userAddress].push(surveyId);
        
        emit SurveyCreated(surveyId, _userAddress);
    }
    
    function updateUserSurvey(
        uint256 _surveyId,
        string memory _occupation, 
        string[] memory _interestedCategories, 
        string[] memory _motivations, 
        string memory _lifeGoals
    ) public {
        require(surveys[_surveyId].surveyId != 0, "Survey does not exist");
        require(surveys[_surveyId].userAddress == msg.sender, "Not authorized to update this survey");
        
        Survey storage surveyToUpdate = surveys[_surveyId];
        surveyToUpdate.occupation = _occupation;
        surveyToUpdate.interestedCategories = _interestedCategories;
        surveyToUpdate.motivations = _motivations;
        surveyToUpdate.lifeGoals = _lifeGoals;
        
        emit SurveyUpdated(_surveyId, msg.sender);
    }
    
    function updateSurvey(
        uint256 _surveyId,
        string memory _occupation, 
        string[] memory _interestedCategories, 
        string[] memory _motivations, 
        string memory _lifeGoals
    ) public onlyOwner {
        require(surveys[_surveyId].surveyId != 0, "Survey does not exist");
        
        Survey storage surveyToUpdate = surveys[_surveyId];
        surveyToUpdate.occupation = _occupation;
        surveyToUpdate.interestedCategories = _interestedCategories;
        surveyToUpdate.motivations = _motivations;
        surveyToUpdate.lifeGoals = _lifeGoals;
        
        emit SurveyUpdated(_surveyId, surveyToUpdate.userAddress);
    }
    
    function getSurveyInfo(uint256 _surveyId) public view returns (
        uint256,
        address, 
        string[] memory, 
        string[] memory, 
        string memory, 
        string memory,
        uint256
    ) {
        Survey storage survey = surveys[_surveyId];
        return (
            survey.surveyId,
            survey.userAddress,
            survey.interestedCategories,
            survey.motivations,
            survey.occupation, 
            survey.lifeGoals,
            survey.createdAt
        );
    }
    
    function getUserSurveyIds(address _userAddress) public view returns (uint256[] memory) {
        return userSurveys[_userAddress];
    }
    
    function getUserSurveyCount(address _userAddress) public view returns (uint256) {
        return userSurveys[_userAddress].length;
    }
    
    function getCurrentUserSurveyCount() public view returns (uint256) {
        return userSurveys[msg.sender].length;
    }
}
