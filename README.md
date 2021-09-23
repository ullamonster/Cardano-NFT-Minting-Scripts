# mintCardanoNFTs
Bash scripts for use on Linux for minting Cardano NFTs

No guarantees on these scripts. They have been tested and work for me. Use at your own risk!

!! This file is incomplete, WIP presently !!

## Assumptions/Prereq's:

 1. You have a Cardano Node running on mainnet...(for testnet replace `--mainnet` entries with the appropriate testnet magic entry, e.g. `--testnet-magic 1097911063`.  I followed this guide, steps 1 - 8 only (not a staking node, just a node): https://www.coincashew.com/coins/overview-ada/guide-how-to-build-a-haskell-stakepool-node
 2. Create some log folders within $NODE_HOME:
    - $NODE_HOME/logs/payments
    - $NODE_HOME/logs/sent
 3. Have a payment.addr file containing your wallet address from your signing computer (can be the same node, but I recommend setting up a "cold" linux computer with the latest cardano-cli installed, generate all your keys and your address there, sign tx's there)
 4. Have the latest params saved to $NODE_HOME/params.json. This is done with the following command from within $NODE_HOME:
```
cardano-cli query protocol-parameters \
    --mainnet \
    --out-file params.json
```
 5. Have your policy skey and vkey files generated and find your policy key-hash.
Generate your policy keys with:
```
cardano-cli address key-gen \
    --verification-key-file policy.vkey \
    --signing-key-file policy.skey
```
Find your policy key-hash with:
```
cardano-cli address key-hash --payment-verification-key-file policy.vkey
```
 6. From your updated policy.script file, containing your policy key-hash and the block number for locking of the policy, you can generate your policy ID with:
```
cardano-cli transaction policyid --script-file policy.script
```
 7. Your $NODE_HOME should also contain the following files, updated for the NFT being minted (assumption is 1 NFT, adjust for multiple by editing your JSON file accordingly):
    - policy.script (the NFT policy script used to generate the ID and containing the block number at which to lock the policy) - This will contain your policy key-hash, found in step 5 above.
    - policy.id (the NFT policy ID generated from step 6 above, with an updated policy.script file)
    - nftmeta.json (the NFT meta data)

 
 ## Instructions
 
 1. Prepare your NFT so it's ready to mint before the next steps
    - Upload the NFT image to IPFS - an easy way to do this is via pinata.cloud, it will generate hash for the pin, called CID on their site, copy this and paste into your nftmeta.json file in the IPFS section like so: ipfs://PastedHashHere
    - Update your nftmeta.json file with any other details, like description, name, etc.
 2. First Time: In your cold environment (or same node if you choose to just do it on one machine) generate your payment keys and policy keys, and finally your policy hash for use in all your related policy.script files. See steps 5 and 6 from Assumptions above.
 3. Ensure your node is sync'd up! This can be done using gLiveView.sh script within your $NODE_HOME folder, should see a smiley face :) or close in diff
 4. Query the tip
 5. Add block time to the resultant/current tip, however much time before this particular policy you are minting to will lock and no longer allow further minting to it.  1800 is about 30 minutes, so calculate how much time you want and add to the tip query result from step 4.
 6. Update your policy.script file with this number in the section with "before", change the numeric value in that section with this number
 7. Generate your policy.id hash from your cold environment (unless you are doing everything on a single hot node)
 8. Paste this ID into your nftmeta.json file for the NFT to be minted
 9. Once these three files (policy.script, policy.id, nftmeta.json) are updated for the current minting on your hot node, run the mintBuildTX.sh script.
  - Run mintBuildTX.sh with 2 inputs, the NFT name (matching the name/ticker from your nftmeta file) and the block height at which locking will occur..this is the same number you added to your policy.script before generating your policy ID, e.g. `./mintBuildTX.sh MyNFT 38022899`
 10. Move the generated file (tx_nft.raw) to your cold environment for signing (or sign on the same node if you are not using a cold environment)
 11. Run the mintSignTX.sh script with the tx_nft.raw file in the same directory
 12. Move the generated tx_nft.signed file back to your hot environment (unless already there if only using a single hot node)
 13. Run the mintSendTX.sh script with the tx_nft.signed file in the same directory
 14. Copy your policy.script, policy.id, and nftmeta.json into a directory for archiving for the given NFT, then you can reuse these as templates for future mintings and edit at will from the node directory & cold environment

## Important Notes

Remove comments from bash files or they'll fail
