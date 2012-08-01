class NotificationSender
  @queue = :notification_sender
  
  def self.perform(auction_id)
    @auction = Auction.find(auction_id)
  end
end