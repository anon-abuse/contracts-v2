pragma solidity ^0.8.17;

import "forge-std/Test.sol";

/// @title Loader
/// @notice Loader contract for loading test data from JSON files.
/// @dev The weird ordering here is because vm.parseJSON requires alphabetical ordering of the fields in the struct, and odd types with conversions are due to the way the JSON is handled.
contract Loader is Test{

    /// @notice represents user data, aka private key, uncompressed and compressed public keys.
    /// access equivalent data by same index.
   struct UserData {
        address payable compressedPublicKey;
        bytes32 privateKey;
        bytes uncompressedPublicKey;
    }


    function loadUserData(string memory root, uint256 keyNumber) public returns (UserData memory) {
        string memory stringNumber = vm.toString(keyNumber);
        
        string memory fileName = string(abi.encodePacked(root, "/keys/keys", stringNumber, ".json"));

        string memory userDataContent = vm.readFile(fileName);

        bytes memory userDataRaw = vm.parseJson(userDataContent);

        UserData memory userData = abi.decode(userDataRaw, (UserData));
    
        return newUserData(userData);
    }

    function newUserData(UserData memory userData)
        public
        pure
        returns (UserData memory)
    {
        return UserData(
            userData.compressedPublicKey,
            userData.privateKey,
            userData.uncompressedPublicKey
        );
    }

    function strToUint(string memory str) internal pure returns (uint256 res) {
        for (uint256 i = 0; i < bytes(str).length; i++) {
            if ((uint8(bytes(str)[i]) - 48) < 0 || (uint8(bytes(str)[i]) - 48) > 9) {
                revert();
            }
            res += (uint8(bytes(str)[i]) - 48) * 10 ** (bytes(str).length - i - 1);
        }

        return res;
    }
}