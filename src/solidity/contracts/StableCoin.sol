// SPDX-License-Identifier: MIT

pragma solidity 0.8.17;
import { ERC20 } from "./ERC20.sol";
import { DepositorCoin } from "./DepositorCoin.sol";
import { Oracle } from "./Oracle.sol";


contract StableCoin is ERC20 {

    DepositorCoin public depositorCoin;
    Oracle public oracle;
    uint256 public feeRatePercentage;
    // this safety check ratio is for the depositer so that he doesn't 
    // deposit just enough and would be potentially liquidated afterwards
    uint256 public constant INITIAL_COLLATERAL_RATIO_PERCENTAGE = 10;


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
        
        // check the current deficit or surplus
        int256 deficitOrSurplusInUsd = _getDeficitOrSurplusInContractInUsd();
        require(deficitOrSurplusInUsd >= 0, "STC: Cannot burn while in deficit");
        _burn(msg.sender, burnStableCoinAmount);

        uint256 refundingEth = burnStableCoinAmount / oracle.getPrice();
        uint256 fee = _getFee(refundingEth);
        uint256 remainingRefundingEth = refundingEth - fee;

        (bool success,) = msg.sender.call{value: remainingRefundingEth}("");
        require(success, "STC: burn transaction failed");
    }

    function depositCollateralBuffer() external payable {
        int256 deficitOrSurplusInUsd = _getDeficitOrSurplusInContractInUsd();

        if (deficitOrSurplusInUsd <= 0) {
            uint256 deficitInUsd = uint256(deficitOrSurplusInUsd * -1);
            uint256 usdInEthPrice = oracle.getPrice();
            uint256 deficitInEth = deficitInUsd / usdInEthPrice;

            // safety check: the depositor needs to deposit at least 10% of the totalsupply
            uint256 requiredInitialSurplusInUsd = (INITIAL_COLLATERAL_RATIO_PERCENTAGE * totalSupply) / 100;
            uint256 requiredInitialSurplusInEth = requiredInitialSurplusInUsd / usdInEthPrice;

            require(
                msg.value >= deficitInEth + requiredInitialSurplusInEth,
                "STC: Initial collateral ratio not met"
            );
            // why? because the amount we are sending now is substracted with the deficit
            // pay attention that if msg.value is lte deficitInEth, transaction will be reverted (underflow), 
            // we add INITIAL_COLLATERAL_RATIO_PERCENTAGE to be more secure about this
            uint256 newInitialSurplusInEth = msg.value - deficitInEth;
            uint256 newInitialSurplusInUsd = newInitialSurplusInEth * usdInEthPrice;

            // for a deficit, we destroy the previous depositorCoin and we do that by creating a new contract
            depositorCoin = new DepositorCoin();
            uint256 mintDepositorCoinAmount = newInitialSurplusInUsd;
            depositorCoin.mint(msg.sender, mintDepositorCoinAmount);

            return;
        }

        /**
        This will convert the int256 value to an equivalent uint256 value.
        If the int256 value is negative, it will be interpreted as a two's complement
        value and converted to the corresponding positive uint256 value.
        For example, if deficitOrSurplus is -1, it will be converted to the uint256 value 2^256 - 1.
        */
        uint256 surplusInUsd = uint256(deficitOrSurplusInUsd);

        // depositor coin in usd price
        uint256 dpcInUsdPrice = _getDpcInUsdPrice(surplusInUsd);
        uint256 mintDepositorCoinAmount = (msg.value * dpcInUsdPrice) / oracle.getPrice();

        depositorCoin.mint(msg.sender, mintDepositorCoinAmount);
    }

    function withdrawCollateralBuffer(uint256 burnDepositorCoinAmount) external {

        require(
            depositorCoin.balanceOf(msg.sender) >= burnDepositorCoinAmount,
            "STC: Sender has insufficient DPC funds"
        );

        depositorCoin.burn(msg.sender, burnDepositorCoinAmount);

        int256 deficitOrSurplusInUsd = _getDeficitOrSurplusInContractInUsd();
        require(deficitOrSurplusInUsd > 0, "STC: No funds to withdraw");

        uint256 surplusInUsd = uint256(deficitOrSurplusInUsd);
        uint256 dpcInUsdPrice = _getDpcInUsdPrice(surplusInUsd);
        uint256 refundingInUsd = burnDepositorCoinAmount / dpcInUsdPrice;
        uint256 refundingInEth = refundingInUsd / oracle.getPrice();

        (bool success,) = msg.sender.call{value: refundingEth}("");

        require(success, "STC: Withdraw refund transaction failed");
    }

    function _getFee(uint ethAmount) private view returns (uint256) {

        bool hasDepositors = address(depositorCoin) != address(0) && depositorCoin.totalSupply() > 0;

        if (!hasDepositors) {
            return 0;
        }
        return (feeRatePercentage * ethAmount) / 100;
    }

    function _getDeficitOrSurplusInContractInUsd() private view reurns (int256) {

        uint256 ethContractBalanceInUsd = (address(this).balance - msg.value) * oracle.getPrice();
        // no conversion, the stableCoin is in usd
        uint256 totalStableCoinBalanceInUsd = totalSupply;
        int256 deficitOrSurplus = int256(ethContractBalanceInUsd) - int256(totalStableCoinBalanceInUsd);

        return deficitOrSurplus;
    }

    function _getDpcInUsdPrice(uint256 surplusInUsd) private view returns (uint256) {
        return depositorCoin.totalSupply() / surplusInUsd;
    }
}