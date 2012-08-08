class QueueAuctionBidder
  @queue = :queue_auction_bidder
  
  # Checks every active auction in the DB to see if their end time is within 5 minutes
  def self.perform
    #@active_keys = $redis.keys("ebay_sniper:auction:*")
    Auction.all.each do |auction|
      if auction.auction_status == "Active" && Time.parse(auction.item[:get_item_response][:item][:listing_details][:end_time]).localtime - Time.now < 300
        #if @auction_keys.include? "ebaysniper:auction:#{auction.id}"
        #  @auction_keys.delete "ebaysniper:auction:#{auction.id}"
          # Should I delete redis key if it exists and just trust that the bidder will continue? I mean, if it fails, there's no point in
          # restarting the bidding process anyways, because 
        if $redis.keys("ebay_sniper:auction:*").include? "ebaysniper:auction:#{auction.id}"
          $redis.del("ebaysniper:auction:#{auction.id}")
        else
          Resque.enqueue(AuctionBidder, auction.id)
        end
      end
    end
  end
end