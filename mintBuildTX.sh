#!/bin/bash
nftName=$1
nftSlot=$2

LOGFOLDER=$NODE_HOME/logs/payments
TIMESTAMP=`date "+%Y-%m-%d_%H-%M-%S"`

# Get UTxO
cardano-cli query utxo \
    --address $(cat payment.addr) \
    --mainnet > fullUtxo.out
tail -n +3 fullUtxo.out | sort -k3 -nr > balance.out
cat balance.out
tx_in=""
total_balance=0
while read -r utxo; do
    in_addr=$(awk '{ print $1 }' <<< "${utxo}")
    idx=$(awk '{ print $2 }' <<< "${utxo}")
    utxo_balance=$(awk '{ print $3 }' <<< "${utxo}")
    total_balance=$((${total_balance}+${utxo_balance}))
    echo TxHash: ${in_addr}#${idx}
    echo ADA: ${utxo_balance}
    tx_in="${tx_in} --tx-in ${in_addr}#${idx}"
done < balance.out
txcnt=$(cat balance.out | wc -l)
echo Total ADA balance: ${total_balance}
echo Number of UTXOs: ${txcnt}
# Draft the tx
cardano-cli transaction build-raw \
    ${tx_in} \
    # NOTE: The following line must end with any other tokens or NFTs held in your UTXO, e.g. append: +"1 policyid.nftname"+"1 policyid.anothernft" (etc)
    # I'm working on a fix to automate this, it seems part of the issue I ran into automating it before was a 'TxOutDatumHashNone' which shows at the UTXO and is appending causing an error.  Working on it.
    --tx-out $(cat payment.addr)+5000000+"1 $(cat policy.id).${nftName}" \
    --invalid-hereafter 0 \
    --fee 0 \
    --mint="1 $(cat policy.id).${nftName}" \
    --minting-script-file policy.script \
    --metadata-json-file nftmeta.json \
    --out-file tx_nft.tmp

# Calculate the fee
fee=$(cardano-cli transaction calculate-min-fee \
    --tx-body-file tx_nft.tmp \
    --tx-in-count ${txcnt} \
    --tx-out-count 1 \
    --witness-count 2 \
    --mainnet \
    --protocol-params-file params.json | awk '{ print $1 }')
    
echo fee: $fee
txOut=$((${total_balance}-${fee}))
echo Change Output: ${txOut}

# Build the TX
echo "=========================="
echo "....Building for: ${tx_in}"
echo "=========================="
echo ""
cardano-cli transaction build-raw \
    ${tx_in} \
    # NOTE: The following line must end with any other tokens or NFTs held in your UTXO, e.g. append: +"1 policyid.nftname"+"1 policyid.anothernft" (etc)
    --tx-out $(cat payment.addr)+${txOut}+"1 $(cat policy.id).${nftName}" \
    --invalid-hereafter ${nftSlot} \
    --fee ${fee} \
    --mint="1 $(cat policy.id).${nftName}" \
    --minting-script-file policy.script \
    --metadata-json-file nftmeta.json \
    --out-file tx_nft.raw

mv fullUtxo.out $LOGFOLDER/${TIMESTAMP}_fullUtxo.out
mv balance.out $LOGFOLDER/${TIMESTAMP}_balance.out
mv tx_nft.tmp $LOGFOLDER/${TIMESTAMP}_tx_nft.tmp
cp tx_nft.raw $LOGFOLDER/${TIMESTAMP}_tx_nft.raw
echo ""
echo "===== Finished ====="
echo "Get and Move tx_nft.raw file to Cold for signing"
echo ""    
