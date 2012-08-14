class QueueAuctionBidder
  @queue = :queue_auction_bidder
  
  # Checks every active auction in the DB to see if their end time is within 5 minutes
  def self.perform
    #@active_keys = $redis.keys("ebay_sniper:auction:*")
    Auction.all.each do |auction|
      if auction.auction_status == "Active" && Time.parse(auction.item[:get_item_response][:item][:listing_details][:end_time]).localtime - Time.now < 300
        #if @auction_keys.include? "ebaysniper:auction:#{auction.id}"
        #  @auction_keys.delete "ebaysniper:auction:#{auction.id}"
          # Should I delete redis key if it exists and just trust that the bidder will continue? If it fails, there's no point in
          # restarting the bidding process anyways, because the auction will have ended.
        unless $redis.keys("ebay_sniper:auction:*").include? "ebaysniper:auction:#{auction.id}"
          Resque.enqueue(AuctionBidder, auction.id)
          #$redis.del("ebaysniper:auction:#{auction.id}")
        end
      end
    end
  end
end