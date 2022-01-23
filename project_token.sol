// SPDX-License-Identifier: MIT
pragma solidity ^0.7.0;

contract assignmentToken {
    uint256 constant MAXSUPPLY = 1000000;
    uint256 supply = 50000;
    address minter = msg.sender;

    // Specify event to be emitted on transfer
    event Transfer(address indexed _from, address indexed _to, uint256 _value);

    // Specify event to be emitted on approval
    event Approval(address indexed _owner, address indexed _spender, uint256 _value);

    event MintershipTransfer(
        address indexed previousMinter,
        address indexed newMinter
    );

    // Create mapping for balances
    mapping (address => uint) public balances;

    // Create mapping for allowances
    mapping (address => mapping(address => uint)) public allowances;

    constructor() {
        // Set sender's balance to total supply
        balances[msg.sender] = supply;
    }

    function totalSupply() public view returns (uint256) {
        // Return total supply
        return supply;
    }

    function balanceOf(address _owner) public view returns (uint256) {
        // Return the balance of _owner
        return balances[_owner];
    }

    function mint(address receiver, uint256 amount) public returns (bool) {
        // Mint tokens by updating receiver's balance and total supply
        // NOTE: total supply must not exceed `MAXSUPPLY`
        require(msg.sender == minter);
        require((amount+supply) < MAXSUPPLY);
        supply += amount;
        balances[receiver] += amount;
        return true;
    }

    function burn(uint256 amount) public returns (bool) {
        // Burn tokens by sending tokens to `address(0)`
        // Must have enough balance to burn
        require(amount <= balances[msg.sender]);
        balances[msg.sender] -= amount;
        balances[address(0)] += amount;
        supply -= amount;
        emit Transfer(msg.sender, address(0), amount);
        return true;
    }

    function transferMintership(address newMinter) public returns (bool) {
        // Transfer mintership to newminter
        // Only incumbent minter can transfer mintership
        // NOTE: should emit `MintershipTransfer` event
        require(msg.sender == minter);
        minter == newMinter;
        emit MintershipTransfer(msg.sender, newMinter);
        return true;
    }

    function transfer(address _to, uint256 _value) public returns (bool) {
        // Transfer `_value` tokens from sender to `_to`
        // Sender needs to have enough tokens
        // Transfer value needs to be sufficient to cover fee
        require(_value <= balances[msg.sender], "Insufficient funds");
        require(_value >= 1, "Insufficient transaction fee");
        balances[msg.sender] -= _value;
        balances[_to] += (_value-1);
        balances[minter] += 1;
        emit Transfer(msg.sender, _to, _value);
        return true;
    }

    function transferFrom(
        address _from,
        address _to,
        uint256 _value
    ) public returns (bool) {
        // Transfer `_value` tokens from `_from` to `_to`
        // NOTE: `_from` needs to have enough tokens and to have allowed sender to spend on his behalf
        // NOTE: transfer value needs to be sufficient to cover fee
        require(_value <= balances[_from], "Not enough funds");
        require(allowances[_from][msg.sender]>=_value, "Insufficient allowance");
        require(_value >= 1, "Insufficient transaction fee");
        balances[_from] -= _value;
        balances[_to] += (_value-1);
        balances[minter] += 1;
        allowances[_from][msg.sender] -= _value;
        emit Transfer(_from, _to, _value);
        return true;
    }

    function approve(address _spender, uint256 _value) public returns (bool) {
        // Allow `_spender` to spend `_value` on sender's behalf
        // NOTE: if an allowance already exists, it should be overwritten
        allowances[msg.sender][_spender] = _value;
        emit Approval(msg.sender, _spender, _value);
        return true;
    }

    function allowance(address _owner, address _spender)
        public
        view
        returns (uint256 remaining)
    { 
        // Return how much `_spender` is allowed to spend on behalf of `_owner`
        return allowances[_owner][_spender];
    }
}
