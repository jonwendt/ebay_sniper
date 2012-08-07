class AuctionBidder
  @queue = :auction_bidder
  
  def self.perform(auction_id)
    @auction = Auction.find(auction_id)
    ebay = EbayAction.new(@auction.user)
    
    if @auction.auction_status != "Deleted"
      # Update auction info
      @auction.item = ebay.get_item(auction_id, "")
    
      # See how long it takes to place a bid by testing with the smallest possible bid
      @time_start = Time.now
      ebay.place_bid(@auction.item_id, @auction.item[:get_item_response][:item][:selling_status][:current_price] + @auction.item[:get_item_response][:item][:selling_status])
      @time_end = Time.now
      @time_diff = @time_end - @time_start
    
      # Sleeps for the time remaining in the auction, minus the time it took to send a place_bid request,
      # and subtracts two more seconds just for good measure (for testing).
      sleep(Time.parse(@auction.item[:get_item_response][:item][:listing_details][:end_time]).localtime - Time.now - @time_diff - 2)
    
      # Places the bid
      ebay.place_bid(@auction.item_id, @auction.max_bid)
    end
  end
end