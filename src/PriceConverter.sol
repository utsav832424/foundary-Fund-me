// SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;

import {AggregatorV3Interface} from "@chainlink/contracts/src/v0.8/interfaces/AggregatorV3Interface.sol";

library PriceConverter {
    function getPrice(
        AggregatorV3Interface getP
    ) internal view returns (uint256) {
        (, int256 answer, , , ) = getP.latestRoundData();
        return uint256(answer * 10000000000);
    }

    function getConversionRate(
        uint256 EthAmount,
        AggregatorV3Interface getP
    ) internal view returns (uint256) {
        uint256 Ethprice = getPrice(getP);
        uint256 EthamountInUsd = (Ethprice * EthAmount) / 1000000000000000000;
        return EthamountInUsd;
    }
}
