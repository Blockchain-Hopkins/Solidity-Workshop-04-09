pragma solidity >=0.7.0 <0.9.0;

/**
* @title House
* @dev A contract that manages a co-living house.
* @dev The landlord can add rooms, and tenants can sign an agreement to rent a room.
* @dev The tenant can pay the landlord's rent and security deposit.
* @dev The landlord can terminate the lease and refund the tenant's deposit.
* @author David Thomas
*/
contract House {
    // TODO: Define the contract's state variables here.

    constructor() {
        // TODO: Initialize the contract's state variables here.
    }

    // STRUCTS -----------------------------------------------------------------

    /**
    * @dev A struct that represents a room in the house.
    */
    struct Room {
        // TODO: Define the Room struct here.
    }

    // TODO: Define the mapping between room numbers and Room structs here.

    /**
    * @dev A struct that represents an agreement between a tenant and the landlord.
    */
    struct Agreement {
        // TODO: Define the Agreement struct here.
    }

    // TODO: Define the mapping between room numbers and Agreement structs here.

    // MODIFIERS -----------------------------------------------------------------

    /**
    * @dev Modifier that checks if the message sender is the landlord.
    */
    modifier onlyLandlord() {
        // TODO: Check if the message sender is the landlord.
    }

    /**
    * @dev Modifier that checks if the message sender is anyone but the landlord.
    */
    modifier notLandlord() {
        // TODO: Check if the message sender is anyone but the landlord.
    }

    /**
    * @dev Modifier that checks if the message sender is a tenant.
    */
    modifier onlyTenant(uint _room_number) {
        // TODO: Check if the message sender is a tenant.
    }

    /**
    * @dev Modifier that check if the room is vacant.
    */
    modifier onlyIfVacant(uint _room_number) {
        // TODO: Check if the room is vacant.
    }

    /**
    * @dev Modifier that checks if a room is occupied.
    */
    modifier onlyIfOccupied(uint _room_number) {
        // TODO: Check if the room is occupied.
    }

    /**
    * @dev Modifier that checks if the tenant has enough to pay the agreement fee.
    */
    modifier enoughAgreementFee(uint _room_number) {
        // TODO: Check if the tenant has enough to pay the agreement fee.
    }

    /**
    * @dev Modifier that checks if the tenant has enough to pay the rent.
    */
    modifier enoughRent(uint _room_number) {
        // TODO: Check if the tenant has enough to pay the rent.
    }

    /**
    * @dev Modifier that checks if there are payments to be made on the lease.
    */
    modifier onlyIfPaymentsLeft(uint _room_number) {
        //TODO: Check if there are payments to be made on the lease.
    }

    /**
    * @dev Modifier that checks if the landlord has enough funds to refund the security deposit.
    */
    modifier enoughSecurityDeposit(uint _room_number) {
        // TODO: Check if the landlord has enough funds to refund the security deposit.
    }

    // FUNCTIONS -----------------------------------------------------------------

    /**
    * @dev Lets the landlord add new rooms to the house.
    * @param _rooms The number of rooms to add.
    * @param _rent_per_month The rent per month of the new rooms.
    * @param _security_deposit The security deposit of the new rooms.
    */
    function addRooms(uint _rooms, uint _rent_per_month, uint _security_deposit) public onlyLandlord() {
        // TODO: Implement the addRooms function here.
    }

    /**
    * @dev Lets anyone view the leasing fee for a room.
    * @param _room_number The room number to view the fee for.
    * @return The leasing fee for the room.
    */
    function getLeasingFee(uint _room_number) public view returns (uint) {
        // TODO: Implement the getLeasingFee function here.
    }

    /**
    * @dev Lets the tenant sign a new agreement with the landlord.
    * @param _room_number The room number of the room to sign the agreement for.
    * @param _lease_duration The lease duration of the agreement.
    * @notice The tenant must pay the security deposit and the first month's rent.
    * @notice The room must be vacant.
    */
    function signAgreement(uint _room_number, uint _lease_duration) public payable notLandlord() enoughAgreementFee(_room_number) onlyIfVacant(_room_number) {
        // TODO: Implement the signAgreement function here.
    }

    /**
    * @dev Lets the tenant see the rent for their room.
    * @param _room_number The room number of the room to see the rent for.
    * @return The rent for the room.
    */
    function getRent(uint _room_number) public view onlyTenant(_room_number) returns (uint) {
        // TODO: Implement the getRent function here.
    }

    /**
    * @dev Lets the tenant pay a monthly rent.
    * @param _room_number The room number of the room to pay the rent for.
    * @notice The tenant must have signed an agreement with the landlord.
    */
    function payRent(uint _room_number) public payable onlyTenant(_room_number) onlyIfPaymentsLeft(_room_number) enoughRent(_room_number) {
        // TODO: Implement the payRent function here.
    }

    /**
    * @dev Lets the landlord terminate a tenant's lease.
    * @param _room_number The room number of the room to terminate the lease for.
    * @notice There must be a tenant in the room.
    * @notice The landlord must have funds to refund the security deposit.
    */
    function terminateAgreement(uint _room_number) public payable onlyLandlord() onlyIfOccupied(_room_number) enoughSecurityDeposit(_room_number) {
        // TODO: Implement the terminateAgreement function here.
    }
}

