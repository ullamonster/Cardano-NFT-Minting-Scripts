#!/bin/bash
cardano-cli transaction sign \
    --tx-body-file tx_nft.raw \
    --signing-key-file payment.skey \
    --signing-key-file policy.skey \
    --mainnet \
    --out-file tx_nft.signed
rm tx_nft.raw
echo ""
echo "===== Finished ====="
echo "move tx_nft.signed back to node for sending!"
