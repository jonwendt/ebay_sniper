class TestJob
  
  @queue = :test_queue
  
  def perform
    # In AuctionBidder, use $redis.setex("ebay_sniper:auction:#{auction.id}", 6.mins.to_i) = "#{Socket.gethostname}:#{Process.pid}" to create a key
    # that expires in 6 minutes (or just longer than the job will need to complete). Then, in QueueAuctionBidder, get a collection of
    # all active auctions that end in less than 5 minutes (or auctions that should have their own workers). Then, get a collection of
    # all redis keys pertaining to bidder jobs that should be running by calling $redis.keys("ebay_sniper:auction:*"). Then, loop through
    # the collection of redis keys, checking the auction.id in the keys against every auction that should be running. If there are any
    # auctions that should be running, but no keys exist pertaining to that auction, then Resque.Enqueue(AuctionBidder, auction.id)
    
    $redis.setex("ebay_sniper:auction:#{auction.id}") = "#{Socket.gethostname}:#{Process.pid}" # Set to expire in 6 minutes (Or just longer than the bidding job)
    
    $redis.keys("ebay_sniper:auction:*") # Get all the keys
    
    valid_workers = Resque.workers # Get all the workers
    
    # Loop through workers, checking if key exists. If true, do nothing (because that means the job is being run when it is supposed to).
    # If it doesn't, then clear the key and enqueue the process using
    # the auction ID, because that means the job failed for some reason. 
    
    

  end
  
end
