pragma solidity ^0.5.0;
import './SignatureVerifier.sol';

contract FunFaceBot is SignatureVerifier{
    mapping (uint256 => address[]) public whitelistForSpace;
    mapping (uint256 => mapping(address => bool)) public whitelistedForSpace;

    // mapping (uint256 => mapping(address => bytes32)) public latestCommittedHashByAddressBySpace;
    mapping (uint256 => mapping(address => uint256)) public timestampByAddressBySpace;
    uint256 latestSpaceCount = 0;

    event newSpaceCreated(uint256);
    event spaceMemberAdded(uint256);
    event whitelisted(address);

    event timestampSet(uint256 timestamp);

    function getUserIndexInWhitelist(address userToCheck, uint256 space) public view returns (uint256) {
        for(uint256 i = 0; i < whitelistForSpace[space].length; i += 1){
            if(whitelistForSpace[space][i] == userToCheck){
                return i;
            }
        }
    }

    function getTimestamp (uint256 space, address userWhoCommittedTimestamp) public view returns (uint256){
        return timestampByAddressBySpace[space][userWhoCommittedTimestamp];
    }

    function commitSignatureTime(uint256 index, uint256 space) public {
        require(whitelistForSpace[space][index] == msg.sender);
        timestampByAddressBySpace[space][msg.sender] = now;
        emit timestampSet(timestampByAddressBySpace[space][msg.sender]);
    }

    function verifySignature(uint256 index, uint256 timestamp, address userRegisteringSpace, uint256 space, uint8 v, bytes32 r, bytes32 s) public view returns (bool){
        require(
            isSigned(
                userRegisteringSpace, 
                keccak256(abi.encodePacked(
                    byte(0x19),
                    byte(0),
                    address(this), 
                    'Generate authorization code', 
                    space,
                    timestamp
            ))
            , v, r, s));
        
        require (
            now - timestamp >= 3600 && 
            timestamp == timestampByAddressBySpace[space][userRegisteringSpace]
        );
        return(whitelistForSpace[space][index] == userRegisteringSpace);
    }

    function createSpace() public returns (uint256){
        latestSpaceCount = latestSpaceCount + 1;
        whitelistForSpace[latestSpaceCount].push(msg.sender);
        whitelistedForSpace[latestSpaceCount][msg.sender] = true;
        emit newSpaceCreated(latestSpaceCount);
        return latestSpaceCount;
    }

    function addTowhitelist (address newMember, uint256 space) public {
        require(whitelistedForSpace[space][msg.sender] == true);
        whitelistForSpace[space].push(newMember);
        whitelistedForSpace[space][newMember] = true;
        emit spaceMemberAdded(space);
        emit whitelisted(newMember);
    }

    function getWhitelistBySpace(uint256 space) public view returns (address[] memory){
        return whitelistForSpace[space];
    }
}

