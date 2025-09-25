// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import {ERC20} from "openzeppelin-contracts/token/ERC20/ERC20.sol";
import {Ownable} from "openzeppelin-contracts/access/Ownable.sol";

/**
 * @title ADVA Token
 * @notice Plain ERC20 with optional burn fee hook support (future), mint controlled by owner (treasury).
 * @dev Keep simple for audit scope; staking/discounts handled off-chain or via future modules.
 */
contract AdvaToken is ERC20, Ownable {
    // Optional fee/burn params (disabled by default)
    uint256 public burnBps; // e.g., 50 = 0.5% burn; set to 0 for off
    address public feeCollector; // optional if you later want protocol fee

    event BurnBpsUpdated(uint256 bps);
    event FeeCollectorUpdated(address indexed collector);

    constructor(address _owner) ERC20("Advataria", "ADVA") Ownable(_owner) {
        // Optionally pre-mint to treasury on deployment, or leave zero and mint via owner later
        // _mint(_owner, 0);
    }

    function setBurnBps(uint256 _bps) external onlyOwner {
        require(_bps <= 200, "max 2%"); // conservative cap
        burnBps = _bps;
        emit BurnBpsUpdated(_bps);
    }

    function setFeeCollector(address _collector) external onlyOwner {
        feeCollector = _collector;
        emit FeeCollectorUpdated(_collector);
    }

    function mint(address to, uint256 amount) external onlyOwner {
        _mint(to, amount);
    }

    // Optional transfer hook with burn; DISABLED unless burnBps>0
    function _update(address from, address to, uint256 value) internal override {
        if (burnBps > 0 && from != address(0) && to != address(0)) {
            uint256 burnAmt = (value * burnBps) / 10_000;
            if (burnAmt > 0) {
                super._update(from, address(0), burnAmt);
                value -= burnAmt;
            }
        }
        super._update(from, to, value);
    }
}
