// SPDX-License-Identifier: MIT

pragma solidity 0.8.17;
import { ERC20 } from "./ERC20.sol";
import { DepositorCoin } from "./DepositorCoin.sol";
import { Oracle } from "./Oracle.sol";


contract StableCoin is ERC20 {

    DepositorCoin public depositorCoin;
    Oracle public oracle;
    uint256 public feeRatePercentage;

    constructor(uint256 _feeRatePercentage, Oracle _oracle) ERC20("StableCoin", "STC") {
        feeRatePercentage = _feeRatePercentage;
        oracle = _oracle;
    }

    function mint() external payable {

        uint256 fee = _getFee(msg.value);
        uint256 remainingEth = msg.value - fee;

        uint256 mintStableCoinAmount = msg.value * oracle.getPrice();
        _mint(msg.sender, mintStableCoinAmount);
    }

    function burn(uint256 burnStableCoinAmount) external {

        _burn(msg.sender, burnStableCoinAmount);

        uint256 refundingEth = burnStableCoinAmount / oracle.getPrice();
        uint256 fee = _getFee(refundingEth);
        uint256 remainingRefundingEth = refundingEth - fee;

        (bool success,) = msg.sender.call{value: remainingRefundingEth}("");
        require(success, "STC: burn transaction failed");
    }

    function _getFee(uint ethAmount) private view returns (uint256) {

        bool hasDepositors = address(depositorCoin) != address(0) && depositorCoin.totalSupply() > 0;

        if (!hasDepositors) {
            return 0;
        }
        return (feeRatePercentage * ethAmount) / 100;
    }
}