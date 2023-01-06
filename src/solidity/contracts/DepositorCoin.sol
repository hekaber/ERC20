// SPDX-License-Identifier: MIT

pragma solidity 0.8.17;
import {ERC20} from "./ERC20.sol";


contract DepositorCoin is ERC20 {
    address public owner;

    constructor() ERC20("DepositorCoin", "DPC") {
        owner = msg.sender;
    }

    function mint(address to, uint256 amount) external {
        require(to == owner, "DPC: only owner can mint");
        _mint(to, amount);
    }

    function burn(address from, uint256 amount) external {
        require(from == owner, "DPC: only owner can burn");
        _burn(from, amount);
    }
}
