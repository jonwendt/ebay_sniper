class AuctionUpdater
  @queue = :auction_updater
  
  # Updates the auction's info.
  def self.perform(auction_id)
    auction = Auction.find(auction_id)
    auction.update_auction
    if auction.auction_status == 'Active'
    	auction.enqueue_job
    end
  end
end