#!/bin/bash
LOGFOLDER=$NODE_HOME/logs/sent
TIMESTAMP=`date "+%Y-%m-%d_%H-%M-%S"`
cardano-cli transaction submit \
    --tx-file tx_nft.signed \
    --mainnet
mv tx_nft.signed $LOGFOLDER/${TIMESTAMP}_tx_nft.signed
echo ""
echo "======= Finished ======"
echo "TX Sent! Check for errors ^"
echo ""
