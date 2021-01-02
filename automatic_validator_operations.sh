#!/bin/bash --

echo "Crypto.com Automatic Validator Operations script by Christian Vari"

if [ "$#" == 0 ]
then
    echo "Please run the script as:"
    echo "./automatic_validator_operations.sh <operatorAddress> <validatorAddress> <keyPassword>"
    exit 0
fi

operatorAddress=$1
validatorAddress=$2
keyPassword=$3
while [ true ]
do
    currentBalance=`./chain-maind query bank balances $operatorAddress --output=json | jq -r ".balances[0].amount"`
    echo "Current balance: $currentBalance"
    currentAvailableReward=`./chain-maind query distribution rewards $operatorAddress --output=json | jq -r ".total[0].amount"`
    echo "Current Availble Delegator Rewards: $currentAvailableReward"
    if (( $(echo "$currentAvailableReward > 10000000000" |bc -l) )) 
    then
            echo "Withdrawing rewards..."
            echo $keyPassword | ./chain-maind tx distribution withdraw-rewards $validatorAddress--commission --from Default --gas 80000000 --gas-prices 0.1basetcro --chain-id "testnet-croeseid-2" -y
    fi
    if (( $(echo "$currentBalance > 10000000000" |bc -l) )) 
    then
            echo "Re-delegating rewards..."
            echo $keyPassword | ./chain-maind tx staking delegate $validatorAddress "$currentBalance"basetcro --from Default --gas 80000000 --gas-prices 0.1basetcro --chain-id "testnet-croeseid-2" -y
    fi
    sleep 1m
done