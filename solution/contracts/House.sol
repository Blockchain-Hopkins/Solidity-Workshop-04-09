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
    address payable landlord;
    uint number_of_rooms;

    constructor() {
        landlord = payable(msg.sender);
        number_of_rooms = 0;
    }

    // STRUCTS -----------------------------------------------------------------

    /**
    * @dev A struct that represents a room in the house.
    */
    struct Room {
        uint room_number;
        uint rent_per_month;
        uint security_deposit;
        bool vacant;
    }

    mapping(uint => Room) public Rooms_by_Number;

    /**
    * @dev A struct that represents an agreement between a tenant and the landlord.
    */
    struct Agreement {
        uint room_number;
        uint lease_duration;
        uint number_of_payments;
        uint timestamp;
        address payable tenant;
    }

    mapping(uint => Agreement) public Agreements_by_Number;

    // MODIFIERS -----------------------------------------------------------------

    /**
    * @dev Modifier that checks if the message sender is the landlord.
    */
    modifier onlyLandlord() {
        require(msg.sender == landlord, "Only the landlord can add rooms");
        _;
    }

    /**
    * @dev Modifier that checks if the message sender is anyone but the landlord.
    */
    modifier notLandlord() {
        require(msg.sender != landlord, "The landlord cannot rent rooms");
        _;
    }

    /**
    * @dev Modifier that checks if the message sender is a tenant.
    */
    modifier onlyTenant(uint _room_number) {
        require(msg.sender == Agreements_by_Number[_room_number].tenant, "Tenant and room do not match");
        _;
    }

    /**
    * @dev Modifier that check if the room is vacant.
    */
    modifier onlyIfVacant(uint _room_number) {
        require(Rooms_by_Number[_room_number].vacant == true, "Room is already occupied");
        _;
    }

    /**
    * @dev Modifier that checks if a room is occupied.
    */
    modifier onlyIfOccupied(uint _room_number) {
        require(Rooms_by_Number[_room_number].vacant == false, "Room is already vacant");
    }

    /**
    * @dev Modifier that checks if the tenant has enough to pay the agreement fee.
    */
    modifier enoughAgreementFee(uint _room_number) {
        uint _total = Rooms_by_Number[_room_number].rent_per_month + Rooms_by_Number[_room_number].security_deposit;
        require(msg.value >= _total, "You don't have enough funds to pay the agreement fee");
        _;
    }

    /**
    * @dev Modifier that checks if the tenant has enough to pay the rent.
    */
    modifier enoughRent(uint _room_number) {
        require(msg.value >= Rooms_by_Number[_room_number].rent_per_month, "Insufficient funds for rent payment");
        _;
    }

    /**
    * @dev Modifier that checks if there are payments to be made on the lease.
    */
    modifier onlyIfPaymentsLeft(uint _room_number) {
        uint _payments_left = Agreements_by_Number[_room_number].lease_duration - Agreements_by_Number[_room_number].number_of_payments;
        require(_payments_left > 0, "Your lease is paid off");
        _;
    }

    /**
    * @dev Modifier that checks if the landlord has enough funds to refund the security deposit.
    */
    modifier enoughSecurityDeposit(uint _room_number) {
        require(msg.value >= Rooms_by_Number[_room_number].security_deposit, "Insufficient funds for deposit refund");
        _;
    }

    // FUNCTIONS -----------------------------------------------------------------

    /**
    * @dev Lets the landlord add new rooms to the house.
    * @param _rooms The number of rooms to add.
    * @param _rent_per_month The rent per month of the new rooms.
    * @param _security_deposit The security deposit of the new rooms.
    */
    function addRooms(uint _rooms, uint _rent_per_month, uint _security_deposit) public pure onlyLandlord() {
        bool _vacancy = true;
        for (uint i = 0; i < _rooms; i++) {
            Rooms_by_Number[number_of_rooms++] = Room(
                number_of_rooms,    // uint room_number;
                _rent_per_month,    // uint rent_per_month
                _security_deposit,  // uint security_deposit
                _vacancy            // bool vacant;
            );
        }
    }

    /**
    * @dev Lets anyone view the leasing fee for a room.
    * @param _room_number The room number to view the fee for.
    * @return The leasing fee for the room.
    */
    function getLeasingFee(uint _room_number) public view returns (uint) {
        return Rooms_by_Number[_room_number].rent_per_month + Rooms_by_Number[_room_number].security_deposit;
    }

    /**
    * @dev Lets the tenant sign a new agreement with the landlord.
    * @param _room_number The room number of the room to sign the agreement for.
    * @param _lease_duration The lease duration of the agreement.
    * @notice The tenant must pay the security deposit and the first month's rent.
    * @notice The room must be vacant.
    */
    function signAgreement(uint _room_number, uint _lease_duration) public payable notLandlord() enoughAgreementFee(_room_number) onlyIfVacant(_room_number) {
        uint _total_fee = Rooms_by_Number[_room_number].rent_per_month + Rooms_by_Number[_room_number].security_deposit;
        landlord.transfer(_total_fee);
        Rooms_by_Number[_room_number].vacant = false;
        Agreements_by_Number[_room_number] = Agreement(
            _room_number,       // uint room_number;
            _lease_duration,    // uint lease_duration;
            1,                  // uint number_of_payments;
            block.timestamp,    // uint timestamp;
            payable(msg.sender) // address payable tenant;
        );
    }

    /**
    * @dev Lets the tenant see the rent for their room.
    * @param _room_number The room number of the room to see the rent for.
    * @return The rent for the room.
    */
    function getRent(uint _room_number) public view onlyTenant(_room_number) returns (uint) {
        return Rooms_by_Number[_room_number].rent_per_month;
    }

    /**
    * @dev Lets the tenant pay a monthly rent.
    * @param _room_number The room number of the room to pay the rent for.
    * @notice The tenant must have signed an agreement with the landlord.
    */
    function payRent(uint _room_number) public payable onlyTenant(_room_number) onlyIfPaymentsLeft(_room_number) enoughRent(_room_number) {
        uint _rent = Rooms_by_Number[_room_number].rent_per_month;
        landlord.transfer(_rent);
    }

    /**
    * @dev Lets the landlord terminate a tenant's lease.
    * @param _room_number The room number of the room to terminate the lease for.
    * @notice There must be a tenant in the room.
    * @notice The landlord must have funds to refund the security deposit.
    */
    function terminateAgreement(uint _room_number) public payable onlyLandlord() onlyIfOccupied(_room_number) enoughSecurityDeposit(_room_number) {
        require(Rooms_by_Number[_room_number].vacant == false, "Room is already vacant");
        uint _security_deposit = Rooms_by_Number[_room_number].security_deposit;
        address payable _tenant = Agreements_by_Number[_room_number].tenant;
        _tenant.transfer(_security_deposit);
        Rooms_by_Number[_room_number].vacant = true;
        Agreements_by_Number[_room_number] = Agreement(
            _room_number,       // uint room_number;
            0,                  // uint lease_duration;
            0,                  // uint number_of_payments;
            0,                  // uint timestamp;
            payable(address(0)) // address payable tenant;
        );
    }
}