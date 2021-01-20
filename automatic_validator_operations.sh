#!/bin/bash --

echo "Crypto.com Automatic Validator Operations script by Christian Vari"

if [ "$#" == 0 ]
then
    echo "Please run the script as:"
    echo "./automatic_validator_operations.sh <delegatorAddress> <operatorAddress> <keyPassword> <keyring> <node>"
    exit 0
fi

delegatorAddress=$1
operatorAddress=$2
keyPassword=$3
keyring=$4
node=$5
while [ true ]
do
    currentBalance=`./chain-maind query bank balances $delegatorAddress --output=json --node $node | jq -r ".balances[0].amount"`
    echo "Current balance: $currentBalance"
    currentAvailableReward=`./chain-maind query distribution rewards $delegatorAddress --output=json --node $node  | jq -r ".total[0].amount"`
    echo "Current Available Delegator Rewards: $currentAvailableReward"
    if (( $(echo "$currentAvailableReward > 10000000000" |bc -l) )) 
    then
            echo "Withdrawing rewards..."
            echo $keyPassword | ./chain-maind tx distribution withdraw-rewards $operatorAddress --commission --from $keyring --gas 80000000 --gas-prices 0.1basetcro --chain-id="crossfire" --keyring-backend="file" --node $node  -y
    fi
    if (( $(echo "$currentBalance > 10000000000" |bc -l) )) 
    then
            echo "Delegating rewards..."
            echo $keyPassword | ./chain-maind tx staking delegate $operatorAddress "$currentBalance"basetcro --from $keyring --gas 80000000 --gas-prices 0.1basetcro --chain-id="crossfire" --keyring-backend="file"--node $node  -y
    fi
    sleep 1m
done
