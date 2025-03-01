# LPSCoin Core - A Luxury Cryptocurrency

[![Build Status](https://travis-ci.org/Luxury-Property-Solutions-LLC/LPSCoin.svg?branch=main)](https://travis-ci.org/Luxury-Property-Solutions-LLC/LPSCoin)
[![GitHub version](https://badge.fury.io/gh/Luxury-Property-Solutions-LLC%2FLPSCoin.svg)](https://badge.fury.io/gh/Luxury-Property-Solutions-LLC%2FLPSCoin)

LPSCoin Core is an innovative cryptocurrency tailored for luxury property transactions, featuring advanced privacy and speed enhancements not found in most digital currencies:
- **Coin Mixing**: Anonymized transactions using cutting-edge mixing technology.
- **FastSend**: Guaranteed zero-confirmation transactions for rapid payments.

Learn more at [lpscoin.org](https://lpscoin.org/) or join the discussion on [GitHub Issues](https://github.com/Luxury-Property-Solutions-LLC/LPSCoin/issues).

## Coin Specifications

| Attribute                  | Value                  |
|----------------------------|------------------------|
| Coin Name                  | LPSCoin                |
| Ticker Symbol              | LPS                    |
| Algorithm                  | Quark                  |
| Type                       | PoW + PoS              |
| Block Time                 | 60 seconds             |
| Difficulty Retargeting     | Every Block            |
| Max Coin Supply            | 91,000,000,000 LPS     |
| Premine/Initial Supply     | 10,000,000,000 LPS     |
| LPS Created Per Block      | 100 LPS                |
| Masternode Collateral      | 25,000 LPS             |
| Block Reward Distribution  | 50% MN / 50% Staker    |
| RPC Port                   | 53473                  |
| Network Port               | 53472                  |

## PoS/PoW Block Details

| Phase             | Blocks         |
|-------------------|----------------|
| Proof of Work     | 1–25,000       |
| Proof of Stake    | 25,001 onward  |

## Getting Started

To build LPSCoin Core from source:
1. Install dependencies (e.g., Boost, OpenSSL, Berkeley DB 4.8).
2. Clone the repo: `git clone https://github.com/Luxury-Property-Solutions-LLC/LPSCoin.git`
3. Build: `./autogen.sh && ./configure --with-gui=qt5 && make`

See [INSTALL](INSTALL) for detailed instructions.

## Contributing

We welcome contributions! Fork the repository, create a branch, and submit a pull request. Please follow our [guidelines](CONTRIBUTING.md).

Join us in building the future of luxury asset transactions!
