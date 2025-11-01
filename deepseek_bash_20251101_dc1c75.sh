cat > scripts/deploy-contract.sh << 'EOF'
#!/bin/bash
echo "🚀 Deploying Wrist Bank Contract to Sui Mainnet..."

# Check if Sui CLI is installed
if ! command -v sui &> /dev/null; then
    echo "❌ Sui CLI not found. Installing..."
    curl -fsSL https://github.com/MystenLabs/sui/releases/download/mainnet-v1.35.0/sui-mainnet-v1.35.0-ubuntu-x86_64.tgz | tar -xzf -
    sudo mv sui-mainnet-v1.35.0-ubuntu-x86_64/bin/sui /usr/local/bin/
fi

# Create contract directory
mkdir -p contracts/sources
cd contracts

# Create Move.toml
cat > Move.toml << 'TOML'
[package]
name = "wrist_bank"
version = "0.1.0"

[dependencies]
Sui = { git = "https://github.com/MystenLabs/sui.git", rev = "mainnet", subdir = "crates/sui-framework/packages/sui-framework" }

[addresses]
wrist_bank = "0x0"
TOML

# Create Watch NFT contract
cat > sources/watch_nft.move << 'MOVE'
module wrist_bank::watch_nft {
    use std::string;
    use sui::object::{Self, UID};
    use sui::transfer;
    use sui::tx_context::{Self, TxContext};
    use sui::url::{Self, Url};
    use sui::event;

    struct WatchNFT has key, store {
        id: UID,
        brand: string::String,
        model: string::String,
        reference: string::String,
        serial: string::String,
        estimated_value: u64,
        image_url: Url,
        year: u64,
        mint_date: u64,
        owner: address
    }

    struct WatchNFTMinted has copy, drop {
        object_id: address,
        brand: string::String,
        model: string::String,
        owner: address
    }

    public entry fun mint_watch_nft(
        brand: vector<u8>,
        model: vector<u8>,
        reference: vector<u8>,
        serial: vector<u8>,
        estimated_value: u64,
        image_url: vector<u8>,
        year: u64,
        ctx: &mut TxContext
    ) {
        let sender = tx_context::sender(ctx);
        
        let watch_nft = WatchNFT {
            id: object::new(ctx),
            brand: string::utf8(brand),
            model: string::utf8(model),
            reference: string::utf8(reference),
            serial: string::utf8(serial),
            estimated_value,
            image_url: url::new_unsafe_from_bytes(image_url),
            year,
            mint_date: tx_context::epoch(ctx),
            owner: sender
        };

        transfer::transfer(watch_nft, sender);
        event::emit(WatchNFTMinted {
            object_id: object::uid_to_inner(&watch_nft.id),
            brand: string::utf8(brand),
            model: string::utf8(model),
            owner: sender
        });
    }

    public fun get_brand(nft: &WatchNFT): &string::String {
        &nft.brand
    }

    public fun get_model(nft: &WatchNFT): &string::String {
        &nft.model
    }

    public fun get_estimated_value(nft: &WatchNFT): u64 {
        nft.estimated_value
    }

    public fun get_owner(nft: &WatchNFT): address {
        nft.owner
    }
}
MOVE

echo "📦 Building contract..."
sui move build

echo "🔑 Please switch to your Sui wallet for deployment..."
echo "💡 Run: sui client switch --address YOUR_WALLET_ADDRESS"

echo "🎯 Ready to deploy! Run: sui client publish --gas-budget 100000000"
EOF