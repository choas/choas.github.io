---
layout:  post
title:   Create an ERC20 LARS Token
date:    2021-12-12 18:04 +0100
image:   roulette-1253626_1280.jpg
tags:    Blockchain Ethereum
excerpt: Starting with a small web3 nodejs example and ending up with an ERC20 LARS token.

---

> The ERC-20 introduces a standard for Fungible Tokens, in other words, they have a property that makes each Token be exactly the same (in type and value) of another Token. For example, an ERC-20 Token acts just like the ETH, meaning that 1 Token is and will always be equal to all the other Tokens. — [ERC-20 TOKEN STANDARD](https://ethereum.org/en/developers/docs/standards/tokens/erc-20/)

I searched for a small 'web3 nodejs' example, because for metaverse and [Decentraland](https://decentraland.org/) you use [Metamask](https://metamask.io/) to log in and synchronize. Everything is based on [Web 3.0](https://en.wikipedia.org/wiki/Web3). And then I ended up creating an ERC20 token.

I found a simple example, forked it and updated the packages: [web3-nodejs](https://github.com/choas/web3-nodejs). It’s always fantastic,NOT 🤔 to see all those _deprecated_ and _no longer supported_ warnings during the installation of Ethereum Node.js packages.  Are people really using those libraries in production?

I installed and started [ganache-cli](https://www.npmjs.com/package/ganache-cli). Run the example and got a result.

Finished?

Yes, if I didn’t have connected the Metamask wallet to my local test-net. I’ve tried to swap some of my test ETHs to BAT ([Basic Attention Token](https://basicattentiontoken.org/)) token, which of course didn’t work.

But what about a token on my test-net? I found this Youtube [How to create an ERC20 Token with Ganache CLI - by Mike Stay @ Pyrofex](https://www.youtube.com/watch?v=UgYlRUlSR4k) video.

## How-to create an ERC20 LARS Token

First download this video and watch it:

```shell
youtube-dl UgYlRUlSR4k
```

Then, if you didn’t have installed the ganache-cli do it und run it:

```shell
npm install -g ganache-cli
ganache-cli
```

This starts a local Ethereum network and creates ten accounts and each has 100 ETH. Don’t jump around like crazy, this isn’t real Ether, but the cool thing is: you don’t have to pay real [Ethereum Gas](https://ethereumprice.org/gas/) :)

### Code

Open the [Remix Ethereum IDE](https://remix.ethereum.org/) and create a `MyToken.sol` file under the contracts folder (which I found [here](https://forum.openzeppelin.com/t/simple-erc20-token-example/4403)):

```javascript
// contracts/SimpleToken.sol
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";

/**
  * @title SimpleToken
  * @dev Very simple ERC20 Token example, where all tokens are pre-assigned to the creator.
  * Note they can later distribute these tokens as they wish using `transfer` and other
  * `ERC20` functions.
  * Based on https://github.com/OpenZeppelin/openzeppelin-contracts/blob/v2.5.1/contracts/examples/SimpleToken.sol
  */
contract SimpleToken is ERC20 {
    /**
      * @dev Constructor that gives msg.sender all of existing tokens.
      */
    constructor(string memory name, string memory symbol, uint256 initialSupply) ERC20(name, symbol) {
      _mint(msg.sender, initialSupply);

    }
}
```

### Deploy Token

Before you deploy the contract, you need to install the Metamask Browser Plugin (e.g. Brave Browser). On the left menu "Deploy & run transactions" select as environment `Injected Web3`.  Watch Metamask or the icon to connect it. Then select SimpleToken as contract and open the deploy dialog. Fill in name, symbol, and initial supply (it’s 1337 with 18 zeros) and then transact. Metamask should open and then confirm the transaction. By the way the suggested gas fee is 0.02498218 ETH (at the moment $100).

![deploy token](/images/Remix_deploy.png)

Remix deploys the contract and if it is successful, you will have a token address (take a look at Deployed Contracts).

### Import Token

Open up Metamask and click on Import token (at the Assets tab on the bottom). Add the Token Contract Address and Metamask should already shows the Token Symbol:

![Metamask import token](/images/Metamask_import_token.png)

Now you have 1337 LARS tokens.

### Token Balance

The simple web3 example could be extended to get the balance for each account:

```javascript
const tokenAddress = '0x8173d2B99480495Daee702A521b1fD7D1191a21e';

accounts.forEach(async (account) => {
  const contract = new web3.eth.Contract(abiJson, tokenAddress);
  const tokenBalance = await contract.methods.balanceOf(account).call();

  console.log(account, tokenBalance);
})
```

The `abiJson` can be found at Remix at the Solidity compiler tab on the bottom. Just copy it and add it in the code. This is the result for my account:

```text
0x4ED8ad0F527C264978b1a6885Cd4C56eCb84070a 1337000000000000000000
```

## Summary

Now I have my own LARS token, a simple one, only on my local network and when I stop ganache-cli they are gone. I’m also not able to swap them — too simple.

If the Ethereum Gas price wouldn’t be so stupid high, I would deploy it just for fun on the real Ethereum blockchain. In case you like this blog post, or want to support me, I have created an Ethereum address: `0xf3522df5621A7E3a25eA02966f1ae28B909A3d4b` … all ETH will be used for LARS tokens and therefore for Gas.

Any questions, comments, or ideas? Write me on Twitter [@choas](https://twitter.com/choas) (DM is open).
