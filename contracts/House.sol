pragma solidity >=0.7.0 <0.9.0;

contract House {
    address payable landlord;

    uint number_of_rooms;

    struct Room {
        uint room_number;
        uint rent_per_month;
        uint security_deposit;
        bool vacant;
    }

    mapping(uint => Room) public Rooms_by_Number;

    struct Agreement {
        uint room_number;
        uint lease_duration;
        uint number_of_payments;
        uint timestamp;
        address payable tenant;
    }

    mapping(uint => Agreement) public Agreements_by_Number;

    struct Payment {
        uint room_number;
        uint amount;
        uint timestamp;
    }

    mapping(uint => Payment[]) public Payments_by_Number;

    //Check if the message sender is the landlord
    modifier onlyLandlord() {
        require(msg.sender == landlord, "Only the landlord can add rooms");
        _;
    }

    // Check if the message sender is anyone but the landlord
    modifier notLandlord() {
        require(msg.sender != landlord, "Only the landlord can add rooms");
        _;
    }

    // Check if the tenant has enough to pay the security deposit and first month's rent
    modifier enoughAgreementFee(uint _room_number) {
        uint _total = Rooms_by_Number[_room_number].rent_per_month + Rooms_by_Number[_room_number].security_deposit;
        require(msg.value >= _total, "You don't have enough funds to pay the agreement fee");
        _;
    }

    // Check if a room is vacant
    modifier onlyIfVacant(uint _room_number) {
        require(Rooms_by_Number[_room_number].vacant == true, "Room is already occupied");
        _;
    }

    // Check if a room is vacant
    modifier onlyTenant(uint _room_number) {
        require(msg.sender == Agreements_by_Number[_room_number].tenant, "Tenant and room do not match");
        _;
    }

    // Check if their are payments to be made on a lease
    modifier onlyIfPaymentsLeft(uint _room_number) {
        uint _payments_left = Agreements_by_Number[_room_number].lease_duration - Agreements_by_Number[_room_number].number_of_payments;
        require(_payments_left > 0, "Your lease is paid off");
        _;
    }

    // Check if the tenant has enough funds to pay rent
    modifier enoughRent(uint _room_number) {
        require(msg.value >= Rooms_by_Number[_room_number].rent_per_month, "Insufficient funds for rent payment");
        _;
    }

    // Check if the landlord has enough funds to refund the security deposit
    modifier enoughSecurityDeposit(uint _room_number) {
        require(msg.value >= Rooms_by_Number[_room_number].security_deposit, "Insufficient funds for deposit refund");
        _;
    }

    // Add empty rooms to the house
    function addRooms(uint _rooms, uint _rent, uint _security_deposit) public onlyLandlord {
        require(msg.sender != address(0));
        bool _vacancy = true;
        for (uint i = 0; i < _rooms; i++) {
            Rooms_by_Number[number_of_rooms++] = Room(
                number_of_rooms,    // uint room_number;
                _rent,              // uint rent_per_month
                _security_deposit,  // uint security_deposit
                _vacancy            // bool vacant;
            );
        }
    }

    // Sign a new agreement between a tenant and the landlord
    function signAgreement(uint _room_number, uint _duration) public payable notLandlord() enoughAgreementFee(_room_number) onlyIfVacant(_room_number) {
        require(msg.sender != address(0));
        uint _total_fee = Rooms_by_Number[_room_number].rent_per_month + Rooms_by_Number[_room_number].security_deposit;
        landlord.transfer(_total_fee);
        Rooms_by_Number[_room_number].vacant = false;
        Agreements_by_Number[_room_number] = Agreement(
            _room_number,       // uint room_number;
            _duration,          // uint lease_duration;
            1,                  // uint number_of_payments;
            block.timestamp,    // uint timestamp;
            payable(msg.sender) // address payable tenant;
        );
        Payments_by_Number[_room_number][0] = Payment(
            _room_number,       // int room_number;
            _total_fee,         // uint amount;
            block.timestamp     // uint timestamp;
        );
    }

    function payRent(uint _room_number) public payable onlyTenant(_room_number) onlyIfPaymentsLeft(_room_number) enoughRent(_room_number) {
        require(msg.sender != address(0));
        uint _rent = Rooms_by_Number[_room_number].rent_per_month;
        landlord.transfer(_rent);
        uint payment_number = Agreements_by_Number[_room_number].number_of_payments;
        Payments_by_Number[_room_number][payment_number] = Payment(
            _room_number,       // int room_number;
            _rent,         // uint amount;
            block.timestamp     // uint timestamp;
        );
    }

    function terminateAgreement(uint _room_number) public payable onlyLandlord() enoughSecurityDeposit(_room_number) {
        require(msg.sender != address(0));
        require(Rooms_by_Number[_room_number].vacant == false, "Room is already vacant");
        uint _security_deposit = Rooms_by_Number[_room_number].security_deposit;
        address payable _tenant = Agreements_by_Number[_room_number].tenant;
        _tenant.transfer(_security_deposit);
        Rooms_by_Number[_room_number].vacant = true;
    }
}