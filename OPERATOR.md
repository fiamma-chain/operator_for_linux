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
./bcli operator -n beta-testnet derive-key -s <MAIN_ADDRESS_PRIVATE_KEY>
```
Use `public_key` to complete the registration process below.

### 4. Register as Operator

> If you have already completed registration, you can skip this section.

Execute the following command in the terminal to register as an operator:

```
./bcli operator -n beta-testnet register --invitation-code <INVITATION_CODE> --main-address <MAIN_ADDRESS> --pegin-address <PEGIN_ADDRESS> --pegout-address <PEGOUT_ADDRESS> --public-key <MAIN_ADDRESS_PUBLIC_KEY>
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

## Quit Operator

If an operator wants to stop receiving new tasks, they can execute the following command to pause receiving new pegin and pegout tasks, but will continue processing already received tasks.

```
./bcli operator -n beta-testnet pause
```

To resume receiving new tasks, execute the following command:

```
./bcli operator -n beta-testnet resume
```

If you want to permanently exit, you need to execute the following command to submit an unregister operator request. Please note that this will not immediately make the operator exit - it only notifies the bridge that the operator wants to exit. You will need to continue running the fiamma-operator for some time to complete all received pegin and pegout tasks.

When the bridge checks that the operator has met the exit conditions (processed all in-progress pegin and pegout tasks), it will automatically broadcast the operator's unstake transaction to help the operator recover their stake funds.

```
./bcli operator -n beta-testnet unstake -a <MAIN_ADDRESS>
```

When the operator's status changes to `Inactive`, you can withdraw all funds from the three addresses to a specified address:

```
./bcli operator -n beta-testnet collect-utxos -r <RECEIVER_ADDRESS>
```

> ⚠️ **Important**: Do not execute the `collect-utxos` command while the operator is still active. This command should only be used after the operator has been fully deactivated and all pending tasks have been completed.

## Query Operator Status

The following commands allow you to query various aspects of the operator's status and performance.

### Query Processing Statistics

To view statistics about the operator's processing activities, including daily and weekly task counts:

```
./bcli query -n beta-testnet processing-stats -i <OPERATOR_ID>
```

This command displays:
- Daily task statistics for the past 7 days
- Total processed pegin and pegout counts
- Weekly new task statistics
- Pending task counts

### Query Pending Tasks

To view pending pegin tasks that need to be processed:

```
./bcli query -n beta-testnet pending-pegin -i <OPERATOR_ID>
```

To view pending pegout tasks that need to be processed:

```
./bcli query -n beta-testnet pending-pegout -i <OPERATOR_ID>
```

These commands show the tasks currently waiting for operator processing, including their IDs, amounts, and update times.

### Query Operator Earnings

To view the operator's earnings from successfully processed tasks:

```
./bcli query -n beta-testnet earnings -i <OPERATOR_ID>
```

This command displays:
- Total earnings (in satoshis)
- Today's earnings
- Monthly earnings

### Query Operator APY

To view the operator's Annual Percentage Yield (APY) based on current performance:

```
./bcli query -n beta-testnet apy -i <OPERATOR_ID>
```

This command displays:
- Current APY percentage
- Historical performance data
- Projected annual returns based on recent activity

Use --help to see more usage for APY query:

```
./bcli query -n beta-testnet apy -i <OPERATOR_ID> --help
```
