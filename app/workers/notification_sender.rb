class NotificationSender
  @queue = :notification_sender
  
  def self.perform(auction_id, message)
    @auction = Auction.find(auction_id)
    @user = @auction.user
    Notification.new.send_sms(message, "6027383570") #@user.number
  end
end