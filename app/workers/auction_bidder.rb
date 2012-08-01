class AuctionBidder
  @queue = :auction_bidder
  
  def self.perform(auction_id)
    e = EbayAction.new
    @auction = Auction.find(auction_id)
    
    # Update auction info
    @auction.item = e.get_item(auction_id, "")
    
    # See how long it takes to place a bid by testing with the smallest possible bid
    @time_start = Time.now
    e.place_bid(@auction.item_id, @auction.item[:get_item_response][:item][:selling_status][:current_price] + @auction.item[:get_item_response][:item][:selling_status])
    @time_end = Time.now
    @time_diff = @time_end - @time_start
    
    # Sleeps for the time remaining in the auction, minus the time it took to send a place_bid request,
    # and subtracts one more second just for good measure.
    sleep(Time.parse(@auction.item[:get_item_response][:item][:listing_details][:end_time]).localtime - Time.now - @time_diff - 1)
    
    # Places the bid
    EbayAction.new.place_bid(@auction.item_id, @auction.max_bid)
  end
end