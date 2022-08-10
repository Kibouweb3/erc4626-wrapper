# erc4626-wrapper

An implementation of [EIP-4626](https://eips.ethereum.org/EIPS/eip-4626) made for education purposes.

EIP-4626 is a Tokenized Vault Standard. In simple terms, you deposit an ERC20 token - you get the vault's token.

This wrapper mints its token at an exchange rate specified by the contract owner with `setExchangeRate(uint256)`.

Got the idea from the [Yield 2022 Mentorship](https://github.com/yieldprotocol/mentorship2022/issues/4).
