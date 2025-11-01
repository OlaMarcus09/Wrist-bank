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

        let nft_id = object::uid_to_inner(&watch_nft.id);
        transfer::transfer(watch_nft, sender);
        
        event::emit(WatchNFTMinted {
            object_id: @nft_id,
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
