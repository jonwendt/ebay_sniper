class AuctionBidder
  @queue = :auction_bidder
  
  def self.perform(auction_id)
    @auction = Auction.find(auction_id)
    EbayAction.new.place_bid(@auction.item_id, @auction.max_bid)
  end
end