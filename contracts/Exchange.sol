// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.0;

import "hardhat/console.sol";
import "./Token.sol";

contract Exchange {
    address public feeAccount;
    uint256 public feePercent;
    // mapping of token address with users addresses it has and how many tokens each user has 
    mapping(address => mapping(address => uint256)) public tokens;

    // Orders mapping (id => Order)
    mapping(uint256 => _Order) public orders;

    // Cancelled orders mapping
    mapping(uint256 => bool) public orderCancelled; // true or false
    mapping(uint256 => bool) public orderFilled; // true or false

    uint256 public ordersCount;

    event Deposit(
        address token, 
        address user, 
        uint256 amount, 
        uint256 balance
    );

    event Withdraw(
        address token, 
        address user, 
        uint256 amount, 
        uint256 balance
    );

    event Order(
        uint256 id,
        address user,
        address tokenGet,
        uint256 amountGet,
        address tokenGive,
        uint256 amountGive,
        uint256 timestamp
    );

    event Cancel(
        uint256 id,
        address user,
        address tokenGet,
        uint256 amountGet,
        address tokenGive,
        uint256 amountGive,
        uint256 timestamp
    );

    event Trade(
        uint256 id,
        address user,
        address tokenGet,
        uint256 amountGet,
        address tokenGive,
        uint256 amountGive,
        address creator,
        uint256 timestamp
    );

    // A way to model order using struct
    struct _Order {
        // Attributes of an order
        uint256 id;             // Unique identifier for order
        address user;           // User who made order
        address tokenGet;       // address of the token they receive
        uint256 amountGet;      // amount they receive
        address tokenGive;      // address of the token they give
        uint256 amountGive;     // amount they give
        uint256 timestamp;      // when order was created
    }

    constructor(address _feeAccount, uint256 _feePercent){
        feeAccount = _feeAccount;
        feePercent = _feePercent;
    }

    // -------------------------
    // DEPOSIT & WITHDRAW TOKEN

    // Deposit Token
    function depositToken(address _token, uint256 _amount) public {
        // Transfer tokens to exchange
        require(Token(_token).transferFrom(msg.sender, address(this), _amount));
        
        // Update user balance
        tokens[_token][msg.sender] = tokens[_token][msg.sender] + _amount; 
        
         // Emit an event 
        emit Deposit(_token, msg.sender, _amount, tokens[_token][msg.sender]);
    }
    
    // Withdraw Token 
    function withdrawToken(address _token, uint256 _amount) public {
        // Ensure user has enough tokens to withdraw        
        require(tokens[_token][msg.sender] >= _amount);

        //Transfer token to user
        Token(_token).transfer(msg.sender, _amount);
        
        // Update user balance
        tokens[_token][msg.sender] = tokens[_token][msg.sender] - _amount; 

        // Emit event
        emit Withdraw(_token, msg.sender, _amount, tokens[_token][msg.sender]);
    }

    // Check Balances
    function balanceOf(address _token, address _user)
        public
        view
        returns (uint256)
    {
        return tokens[_token][_user];
    }

    /*---------------------
    // MAKE & CANCEL ORDER
    -----------------------*/

    // Token Give (the token the want to spend) - which token and how much?
    // Token Get (the token they want to receive) - which token and how much?

    function makeOrder(
        address _tokenGet, 
        uint256 _amountGet, 
        address _tokenGive, 
        uint256 _amountGive
    ) public {
        // Prevent orders if tokens aren't on exchange
        require(balanceOf(_tokenGive, msg.sender) >= _amountGive);

        // Initiate new Order
        ordersCount++;

        orders[ordersCount] = _Order(
            ordersCount,        // id
            msg.sender,         // user
            _tokenGet,          // tokenGet
            _amountGet,         // amountGet
            _tokenGive,         // tokenGive
            _amountGive,        // amountGive
            block.timestamp     //timestamp
        );

        // Emit Order event
        emit Order(
            ordersCount,
            msg.sender,
            _tokenGet,
            _amountGet,
            _tokenGive,
            _amountGive,
            block.timestamp
        );
    }

    function cancelOrder(uint256 _id) public {
        // Fetch Order
        _Order storage _order = orders[_id];
        
        // Ensure the caller of the function is the owner of the order
        require(address(_order.user) == msg.sender);

        // Order must exist
        require(_order.id == _id);

        // Cancel Order
        orderCancelled[_id] = true;


        // Emit event
        emit Cancel(
            _order.id,
            msg.sender,
            _order.tokenGet,
            _order.amountGet,
            _order.tokenGive,
            _order.amountGive,
            block.timestamp
        );
    }

    /*------------------
      EXECUTING ORDERS
    -------------------*/

    function fillOrder(uint256 _id) public {
        // Must be valid orderId
        require(_id > 0 && _id <= ordersCount, 'Order does not exist');
        // Order can't get filled
        require(!orderFilled[_id], 'Order is already filled');
        // Order can't be cancelled
        require(!orderCancelled[_id], 'Order is cancelled');

        // Fetch orders
        _Order storage _order = orders[_id];

        // Swapping Tokens (Trading)
        _trade(
            _order.id, 
            _order.user, 
            _order.tokenGet, 
            _order.amountGet, 
            _order.tokenGive,
            _order.amountGive
        );

        // Mark order as filled
        orderFilled[_order.id] = true;
    }

    function _trade(
        uint256 _orderId, 
        address _user,
        address _tokenGet,
        uint256 _amountGet,
        address _tokenGive,
        uint256 _amountGive
    ) internal {
        // Fee is paid by the user who filled the order(msg.sender)
        // Fee deducted from _amountGet
        uint256 _feeAmount = (_amountGet * feePercent) / 100;

        // Execute Trade
        // msg.sender is the user who filled the order, while _user is who created the order
        tokens[_tokenGet][msg.sender] = tokens[_tokenGet][msg.sender] - (_amountGet + _feeAmount);
        tokens[_tokenGet][_user] = tokens[_tokenGet][_user] + _amountGet;

        // Charge fees
        tokens[_tokenGet][feeAccount] = tokens[_tokenGet][feeAccount] + _feeAmount;

        tokens[_tokenGive][_user] = tokens[_tokenGive][_user] - _amountGive;
        tokens[_tokenGive][msg.sender] = tokens[_tokenGive][msg.sender] + _amountGive;

        // Emit trade event
        emit Trade(
            _orderId,
            msg.sender,
            _tokenGet,
            _amountGet,
            _tokenGive,
            _amountGive,
            _user,
            block.timestamp
        );
    }
}