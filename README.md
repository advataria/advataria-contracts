# Advataria Smart Contracts (MVP)

**Advataria** is a marketplace for AI-powered video ads. Businesses create pro-quality ads in ≤10 minutes for **<$10**; creators monetize **AI Actor™** avatars via on-chain licensing and automated royalties.

This repo contains the **MVP smart contracts**:

- **AdvaToken.sol** — ERC-20 utility token (ADVA) with optional burn hook (disabled by default).
- **LinearVesting.sol** — linear vesting with cliff for team/investors/eco.
- **LicensingEscrow.sol** — holds advertiser payments and releases to the **AI Actor NFT** owner (creator) minus platform fee.
- **RoyaltySplitter.sol** — pull-based splitter for multi-party royalty distribution (creator / platform / co-creator).

## Why
Video advertising is expensive and slow; AI avatars lack clear licensing & royalties. Advataria delivers a **practical, low-cost** solution with **on-chain** licensing and payouts.

## Stack
- Solidity `^0.8.24`
- OpenZeppelin Contracts
- Foundry (forge, cast)

## Quick Start

```bash
# 1) Install Foundry
curl -L https://foundry.paradigm.xyz | bash
foundryup

# 2) Init OZ libs
forge install OpenZeppelin/openzeppelin-contracts --no-commit

# 3) Build & test
forge build
forge test -vv
