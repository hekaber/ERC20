// SPDX-License-Identifier: MIT
pragma solidity 0.8.17;

// why Wad? because it's called like that when having 18 decimals
library WadLib {
    uint256 public constant MULTIPLIER = 10e18;

    struct Wad {
        uint256 value;
    }

    function mulWad(uint256 number, Wad memory wad) internal pure returns (uint256) {
        return (number * wad.value) / MULTIPLIER;
    }

    function divWad(uint256 number, Wad memory wad) internal pure returns (uint256) {
        return (number * MULTIPLIER) / wad.value;
    }

    function fromFraction(uint256 numerator, uint256 denominator) internal pure returns (Wad memory) {
        if (numerator == 0) {
            return Wad(0);
        }

        return Wad((numerator * MULTIPLIER) / denominator);
    }
}