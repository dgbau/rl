# Blockchain & Smart Contract Development

<!-- category: template -->

## Overview

Smart contract development, testing, deployment, and frontend wallet integration
for EVM-compatible chains.

## Framework

[FILL: Foundry / Hardhat]

- **Foundry**: Rust-based, fast compilation, native fuzzing, Solidity tests, `forge`, `cast`, `anvil`
- **Hardhat**: JavaScript/TypeScript, rich plugin ecosystem, `console.log` in Solidity, broader community

## Solidity Patterns

```solidity
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/security/ReentrancyGuard.sol";
import "@openzeppelin/contracts/token/ERC721/ERC721.sol";

contract MyContract is ERC721, Ownable, ReentrancyGuard {
    // Use custom errors over require strings — saves gas
    error InsufficientPayment();
    error MaxSupplyReached();

    uint256 public constant MAX_SUPPLY = 10_000;
    uint256 private _nextTokenId;

    constructor() ERC721("Name", "SYM") Ownable(msg.sender) {}

    function mint() external payable nonReentrant {
        if (msg.value < 0.01 ether) revert InsufficientPayment();
        if (_nextTokenId >= MAX_SUPPLY) revert MaxSupplyReached();
        _safeMint(msg.sender, _nextTokenId++);
    }
}
```

## OpenZeppelin Usage

- Always use audited OpenZeppelin contracts as base: `Ownable`, `Pausable`, `ReentrancyGuard`
- Use `@openzeppelin/contracts-upgradeable` for proxy patterns (UUPS preferred over Transparent)
- Pin exact OpenZeppelin version in dependencies

## Wallet Integration (wagmi + viem)

```typescript
import { createConfig, http } from 'wagmi';
import { mainnet, sepolia } from 'wagmi/chains';
import { injected, walletConnect } from 'wagmi/connectors';

export const config = createConfig({
  chains: [mainnet, sepolia],
  connectors: [injected(), walletConnect({ projectId: '[FILL: WalletConnect project ID]' })],
  transports: {
    [mainnet.id]: http('[FILL: RPC URL]'),
    [sepolia.id]: http(),
  },
});
```

- Use `useAccount`, `useConnect`, `useWriteContract`, `useWaitForTransactionReceipt`
- Always show transaction status: pending, confirming, confirmed, failed

## Gas Optimization

- Pack storage variables (multiple `uint128` in one slot vs separate `uint256`)
- Use `calldata` instead of `memory` for read-only function parameters
- Prefer mappings over arrays for lookups
- Use custom errors instead of `require` with string messages
- Minimize SSTORE operations; batch state changes
- Use `unchecked {}` for arithmetic that provably cannot overflow

## IPFS Pinning

- Pin metadata and assets to IPFS via Pinata, nft.storage, or self-hosted IPFS node
- Store only the CID on-chain (immutable content addressing)
- Use `ipfs://` URIs in tokenURI; frontends resolve via gateway

## Security Checklist

- [ ] Reentrancy protection on all external-calling functions
- [ ] Check-Effects-Interactions pattern
- [ ] Access control on sensitive functions (`onlyOwner`, role-based)
- [ ] Integer overflow safe (Solidity 0.8+ default, but verify `unchecked` blocks)
- [ ] No `tx.origin` for authentication — use `msg.sender`
- [ ] Front-running mitigation (commit-reveal, MEV protection)
- [ ] Audit with Slither, Mythril, or Aderyn before mainnet deployment
- [ ] Testnet deployment and verification on Etherscan before mainnet

## Testing & Deployment

- Foundry: `forge test --fork-url $RPC_URL -vvv` for fork tests; `--fuzz-runs 10000` for fuzzing
- Hardhat: `npx hardhat test --network hardhat`
- Write invariant tests for critical protocol properties
- Test edge cases: zero values, max uint, empty arrays, reentrancy attempts
- Use deterministic deployment (CREATE2) for predictable addresses across chains
- Verify contracts on block explorers immediately; store addresses/ABIs in version control
