// SPDX-License-Identifier: GPD-3.0
pragma solidity >0.4.0 <0.9.0;

contract FoodDeliverySystem {
    struct Restaurant {
        string name;
        address payable wallet;
    }

    struct Customer {
        string name;
        address payable wallet;
    }

 address public owner = msg.sender;
   


    enum OrderStatus { Placed, InProgress, Delivered, Canceled }

    struct Order {
        address customer;
        address restaurant;
        uint256 amount;
        OrderStatus status;
    }

    mapping(address => Restaurant) public restaurants;
    mapping(address => Customer) public customers;
    mapping(uint256 => Order) public orders;

    uint256 public orderCounter;

    // Events
    event OrderPlaced(uint256 orderId, address indexed customer, address indexed restaurant, uint256 amount);
    event OrderInProgress(uint256 orderId);
    event OrderDelivered(uint256 orderId);
    event OrderCanceled(uint256 orderId);

    // Modifier: Ensures that only the restaurant can call the function
    modifier onlyRestaurant() {
        require(restaurants[msg.sender].wallet != address(0), "Only the restaurant can call this function");
        _;
    }

    // Modifier: Ensures that only the customer can call the function
    modifier onlyCustomer() {
        require(customers[msg.sender].wallet != address(0), "Only the customer can call this function");
        _;
    }

    

    // Function: Place a food order
    function placeOrder(address _restaurant, uint256 _amount) public onlyCustomer {
        require(_amount > 0, "Order amount must be greater than 0");

        orderCounter++;
        orders[orderCounter] = Order(msg.sender, _restaurant, _amount, OrderStatus.Placed);

        emit OrderPlaced(orderCounter, msg.sender, _restaurant, _amount);
    }

    // Function: Confirm order in progress (only the restaurant)
    function confirmOrderInProgress(uint256 _orderId) public onlyRestaurant {
        Order storage order = orders[_orderId];
        require(order.restaurant == msg.sender, "You are not authorized to confirm this order");

        order.status = OrderStatus.InProgress;

        emit OrderInProgress(_orderId);
    }

    // Function: Confirm order delivery (only the restaurant)
    function confirmOrderDelivered(uint256 _orderId) public onlyRestaurant {
        Order storage order = orders[_orderId];
        require(order.restaurant == msg.sender, "You are not authorized to confirm this order");

        order.status = OrderStatus.Delivered;

        // Transfer the funds to the restaurant's wallet
        restaurants[order.restaurant].wallet.transfer(order.amount);

        emit OrderDelivered(_orderId);
    }

// Variable to store the total balance received by the contract
    uint public balanceReceived;

    // Function to receive money (ETH) to the contract
    function receivedMoney() public payable {
        balanceReceived += msg.value;
    }

    // Function to get the current balance of the contract
    function getBalance() public view returns(uint) {
        return address(this).balance;
    }

    // Function to allow the owner to withdraw funds from the contract
    function withdrawMoneyTo(address payable _to) public {
        require(msg.sender == owner, "Only owner can withdraw funds");
        _to.transfer(getBalance());
    }
    // Function: Cancel an order (only the customer)
    function cancelOrder(uint256 _orderId) public onlyCustomer {
        Order storage order = orders[_orderId];
        require(order.customer == msg.sender, "You are not authorized to cancel this order");

        order.status = OrderStatus.Canceled;

        // Refund the funds to the customer's wallet
        customers[order.customer].wallet.transfer(order.amount);

        emit OrderCanceled(_orderId);
    }

    
}
