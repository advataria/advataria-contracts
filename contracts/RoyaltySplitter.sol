// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import {IERC20} from "openzeppelin-contracts/token/ERC20/IERC20.sol";
import {Ownable} from "openzeppelin-contracts/access/Ownable.sol";

/**
 * @title LinearVesting
 * @notice Simple linear vesting with optional cliff; pull-based claims by beneficiaries.
 */
contract LinearVesting is Ownable {
    struct Grant {
        uint256 total;
        uint64  start;   // unix
        uint64  cliff;   // unix
        uint64  end;     // unix
        uint256 claimed;
    }

    IERC20 public immutable token;
    mapping(address => Grant) public grants;

    event GrantCreated(address indexed beneficiary, uint256 total, uint64 start, uint64 cliff, uint64 end);
    event Claimed(address indexed beneficiary, uint256 amount);

    constructor(IERC20 _token, address _owner) {
        token = _token;
        _transferOwnership(_owner);
    }

    function createGrant(
        address beneficiary,
        uint256 total,
        uint64 start,
        uint64 cliff,
        uint64 end
    ) external onlyOwner {
        require(grants[beneficiary].total == 0, "grant exists");
        require(start <= cliff && cliff <= end, "timing");
        grants[beneficiary] = Grant(total, start, cliff, end, 0);
        emit GrantCreated(beneficiary, total, start, cliff, end);
    }

    function vested(address beneficiary, uint64 t) public view returns (uint256) {
        Grant memory g = grants[beneficiary];
        if (g.total == 0) return 0;
        if (t < g.cliff) return 0;
        if (t >= g.end) return g.total;
        // linear between cliff..end
        return (g.total * (t - g.cliff)) / (g.end - g.cliff);
    }

    function claim() external {
        Grant storage g = grants[msg.sender];
        require(g.total > 0, "no grant");
        uint256 v = vested(msg.sender, uint64(block.timestamp));
        uint256 due = v - g.claimed;
        require(due > 0, "nothing");
        g.claimed += due;
        require(token.transfer(msg.sender, due), "transfer fail");
        emit Claimed(msg.sender, due);
    }

    // Owner can fund this contract with tokens beforehand
}
