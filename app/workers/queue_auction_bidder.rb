class QueueAuctionBidder
  @queue = :queue_auction_bidder
  
  # Checks every active auction in the DB to see if their end time is within 5 minutes
  def self.perform
    Auction.all.each do |auction|
      if auction.auction_status == "Active" && Time.parse(auction.item[:get_item_response][:item][:listing_details][:end_time]).localtime - Time.now < 300
        unless $redis.keys("ebay_sniper:auction:*").include? "ebay_sniper:auction:#{auction.id}"
          Resque.enqueue(AuctionBidder, auction.id)
        end
      end
    end
  end
end


# Delete key
  # $redis.del("ebay_sniper:auction:#{auction.id}")