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

### 2. Prepare Bitcoin Addresses and Ethereum Address

Prepare the private keys for the **3 Bitcoin addresses** configured when starting the Fiamma Operator program: main address, pegin processing address, and pegout processing address. Please make sure to use 3 different Bitcoin addresses to prevent large UTXOs from being accidentally locked by pre-signed transactions. While funds won't be lost, it will reduce capital utilization.

> Please use p2tr type addresses

Additionally, you need to prepare **1 Ethereum address** for the operator EVM secret key, which is used for staking FiaBTC. This corresponds to the `BITVM_BRIDGE_OPERATOR_ETH_SK` configuration in your `.env` file.

> **Note**: You can obtain FiaBTC through pegin tasks on the bridge.

### 3. Get Main Account Public Key

The main address's public key is required for registration. Here's how to obtain it:

```
cd operator_for_linux
./bcli operator -n mainnet derive-key -s <MAIN_ADDRESS_PRIVATE_KEY>
```
Use `public_key` to complete the registration process below.

### 4. Register as Operator

> If you have already completed registration, you can skip this section.

Execute the following command in the terminal to register as an operator:

```
./bcli operator -n mainnet register --invitation-code <INVITATION_CODE> --main-address <MAIN_ADDRESS> --pegin-address <PEGIN_ADDRESS> --pegout-address <PEGOUT_ADDRESS> --public-key <MAIN_ADDRESS_PUBLIC_KEY> --evm-address <EVM_ADDRESS>
```

## Operator Staking Process

> If you have already completed staking, you can skip this section.

After the Operator program starts running, it needs to stake BTC before starting work. If the operator behaves properly (does not act maliciously), they can unstake their BTC after completing their work.

**Important**: Staking requires FiaBTC tokens as staking collateral on the EVM address, and ETH for gas fees. You can obtain FiaBTC through the bridge at https://app.fiammalabs.io/bridge

### 1. Transfer Funds
To successfully complete staking, you need to transfer sufficient BTC to the operator's main address, at least `stake_amount` + `dust` + `gas` BTC.

> Currently, `stake_amount` is 1 BTC, so transfer at least 1.00001 BTC. Since subsequent work requires 15 BTC, it's recommended to transfer at least 16.00001 BTC initially.

### 2. Stake Funds
When the operator's main address has sufficient BTC and the EVM address has enough FiaBTC for gas fees, execute the following command to complete staking:

> **⚠️ Important Performance Requirements:**
> This command will generate BTC scripts and complete ETH-BTC staking operations. You need a high-performance machine (minimum 4 CPU cores and 48GB RAM) to run this command successfully. Depending on your machine's performance, this process may take 5-20 minutes to complete.
>
> **Please ensure:**
> - Keep your terminal session active during the entire process
> - Do not exit or interrupt the command while it's running
> - Consider using `nohup` to run the command in the background if needed

```
./bcli operator -n mainnet stake
```

**Alternative command using nohup (recommended for stability):**

If you want to run the staking process in the background to avoid terminal disconnection issues, use the following commands:

1. **Start the staking process with nohup:**
```
nohup ./bcli operator -n mainnet stake > stake.log 2>&1 &
```

2. **Get the process ID (will be displayed after running the command):**
The system will show something like: `[1] 12345` (where 12345 is the process ID)

3. **Monitor the progress in real-time:**
```
tail -f stake.log
```
Press `Ctrl+C` to stop monitoring (this won't stop the staking process)

4. **Check if the process is still running:**
```
ps aux | grep "bcli operator"
```

Check staking status:

```
./bcli query -n mainnet stake -a <MAIN_ADDRESS>
```

When the staking status is `committee_signed`, wait for the stake transaction to be confirmed on the blockchain (about 10 minutes), then you can check the operator status:

```
./bcli query -n mainnet operator -a <MAIN_ADDRESS>
```

If the `status` is `Active`, it means the operator has completed the staking process and has started working.

## Quit Operator

If an operator wants to stop receiving new tasks, they can execute the following command to pause receiving new pegin and pegout tasks, but will continue processing already received tasks.

```
./bcli operator -n mainnet pause
```

To resume receiving new tasks, execute the following command:

```
./bcli operator -n mainnet resume
```

If you want to permanently exit, you need to execute the following command to submit an unregister operator request. Please note that this will not immediately make the operator exit - it only notifies the bridge that the operator wants to exit. You will need to continue running the fiamma-operator for some time to complete all received pegin and pegout tasks.

When the bridge checks that the operator has met the exit conditions (processed all in-progress pegin and pegout tasks), it will automatically broadcast the operator's unstake transaction to help the operator recover their stake funds.

```
./bcli operator -n mainnet unstake -a <MAIN_ADDRESS>
```

When the operator's status changes to `Inactive`, you can withdraw all funds from the three addresses to a specified address:

```
./bcli operator -n mainnet collect-utxos -r <RECEIVER_ADDRESS>
```

> ⚠️ **Important**: Do not execute the `collect-utxos` command while the operator is still active. This command should only be used after the operator has been fully deactivated and all pending tasks have been completed.

## Query Operator Status

The following commands allow you to query various aspects of the operator's status and performance.

### Query Processing Statistics

To view statistics about the operator's processing activities, including daily and weekly task counts:

```
./bcli query -n mainnet processing-stats -i <OPERATOR_ID>
```

This command displays:
- Daily task statistics for the past 7 days
- Total processed pegin and pegout counts
- Weekly new task statistics
- Pending task counts

### Query Pending Tasks

To view pending pegin tasks that need to be processed:

```
./bcli query -n mainnet pending-pegin -i <OPERATOR_ID>
```

To view pending pegout tasks that need to be processed:

```
./bcli query -n mainnet pending-pegout -i <OPERATOR_ID>
```

These commands show the tasks currently waiting for operator processing, including their IDs, amounts, and update times.

### Query Operator Earnings

To view the operator's earnings from successfully processed tasks:

```
./bcli query -n mainnet earnings -i <OPERATOR_ID>
```

This command displays:
- Total earnings (in satoshis)
- Today's earnings
- Monthly earnings

### Query Operator APY

To view the operator's Annual Percentage Yield (APY) based on current performance:

```
./bcli query -n mainnet apy -i <OPERATOR_ID>
```

This command displays:
- Current APY percentage
- Historical performance data
- Projected annual returns based on recent activity

Use --help to see more usage for APY query:

```
./bcli query -n mainnet apy -i <OPERATOR_ID> --help
```
