// SPDX-License-Identifier: GPL-3.0
pragma solidity ^0.8.29;

import {IERC20} from "@openzeppelin/contracts/interfaces/IERC20.sol";
import {IFeed} from "../interface/Feed.sol";

library FeedLib {
    /**
     * Gets the bid-token of feed.
     *
     * @param feed to query
     * @return token for bid of feed
     */
    function bidToken(IFeed feed) internal view returns (IERC20 token) {
        return IERC20(feed.getBidToken());
    }

    /**
     * Gets the ask-token of feed.
     *
     * @param feed to query
     * @return token for ask of feed
     */
    function askToken(IFeed feed) internal view returns (IERC20 token) {
        return IERC20(feed.getAskToken());
    }
}
