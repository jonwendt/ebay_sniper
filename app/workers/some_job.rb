class SomeJob
  @queue = :some_queue
  
  def self.perform(user_id)
    user = User.find(user_id)
    user.auctions.each do |auction|
      auction.max_bid = "1337"
      auction.save
    end
  end
end
