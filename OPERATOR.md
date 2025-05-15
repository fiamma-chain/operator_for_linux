# Fiamma Operator for Linux

## Prerequisites: Installing and Running `Fiamma Operator Backend Program`

Ensure the operator backend program is properly running before attempting to execute any of the following commands.

To run operator program, you need to:
1. Installing necessary dependencies
2. Setting up the required configuration files
3. Starting the fiamma-operator program

Please refer to the [README.md](./README.md) for more details.


## Operator Registration Process

When running the operator for the first time, you need to use an invitation code to register the operator address in the Fiamma bridge. Currently, only users and institutions with invitation codes can register as operators.

### 1. Get Invitation Code

Please contact Fiamma personnel to obtain your exclusive invitation code `invite_code`

### 2. Prepare Bitcoin Addresses

Prepare the private keys for the 3 Bitcoin addresses configured when starting the Fiamma Operator program: main address, pegin processing address, and pegout processing address. Please make sure to use 3 different Bitcoin addresses to prevent large UTXOs from being accidentally locked by pre-signed transactions. While funds won't be lost, it will reduce capital utilization.

> Please use p2tr type addresses

### 3. Get Main Account Public Key

The main address's public key is required for registration. Here's how to obtain it:

```
cd operator_for_linux
./bcli operator -n testnet4 derive-key -s `private_key_of_main_address`
```
Use `public_key` to complete the registration process below.

### 4. Register as Operator

> If you have already completed registration, you can skip this section.

Execute the following command in the terminal to register as an operator:

```
./bcli operator register --invitation-code <INVITATION_CODE> --main-address <MAIN_ADDRESS> --pegin-address <PEGIN_ADDRESS> --pegout-address <PEGOUT_ADDRESS> --public-key <PUBLIC_KEY>
```

## Operator Staking Process

> If you have already completed staking, you can skip this section.

After the Operator program starts running, it needs to stake BTC before starting work. If the operator behaves properly (does not act maliciously), they can unstake their BTC after completing their work.

### 1. Transfer Funds
To successfully complete staking, you need to transfer sufficient BTC to the operator's main address, at least `stake_amount` + `dust` + `gas` BTC.

> Currently, `stake_amount` is 1 BTC, so transfer at least 1.00001 BTC. Since subsequent work requires 12 BTC, it's recommended to transfer at least 13.00001 BTC initially.

### 2. Stake Funds

When the operator's main address has sufficient BTC, execute the following command to complete staking:

```
./bcli operator -n beta-testnet stake
```

Check staking status:

```
./bcli query -n beta-testnet stake -a <MAIN_ADDRESS>
```

When the staking status is `committee_signed`, wait for the stake transaction to be confirmed on the blockchain (about 10 minutes), then you can check the operator status:

```
./bcli query -n beta-testnet operator -a <MAIN_ADDRESS>
```

If the `status` is `Active`, it means the operator has completed the staking process and has started working.

