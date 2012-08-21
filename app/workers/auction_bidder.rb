class AuctionBidder
  @queue = :auction_bidder
  
  def self.perform(auction_id)
    
    auction = Auction.find(auction_id)
    ebay = EbayAction.new(auction.user)
    $redis.setex("ebay_sniper:auction:#{auction_id}", 6.minutes.to_i, "#{Socket.gethostname}:#{Process.pid}")
    
    if auction.auction_status != "Deleted"
      # Update auction info
      auction.item = ebay.get_item(auction.item_id, nil)
      
      # Sleeps until just before the auction ends.
      sleep_time = Time.parse(auction.item[:get_item_response][:item][:listing_details][:end_time]).localtime - Time.now - 5 - auction.lead_time
      unless sleep_time < 0
        sleep(sleep_time)
      end
      
      # Updates the auction info (in case the user changed something in the last ~5 minutes)
      auction = Auction.find(auction_id)
      
      # Sleeps for the time remaining in the auction, and subtracts 1.5 seconds to account for time needed to place bid.
      sleep_time = Time.parse(auction.item[:get_item_response][:item][:listing_details][:end_time]).localtime - Time.now - 1.5 - auction.lead_time
      unless sleep_time < 0
        sleep(sleep_time)
      end
      
      # Does another check to make sure the user hasn't deleted the auction in the time the job was sleeping
      if auction.auction_status != "Deleted"
        # Places the bid
        ebay.place_bid(auction.item_id, auction.max_bid)
        
        # The bid has been placed. Now just wait a few seconds until the auction is definitely over and update it.
        sleep(2 + auction.lead_time)
        auction.update_auction
      end
    end
  end
end