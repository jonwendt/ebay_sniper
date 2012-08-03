class NotificationSender
  @queue = :notification_sender
  
  def self.perform(auction_id, message)
    @auction = Auction.find(auction_id)
    @user = @auction.user
    Notification.new.send_sms(message, @user.phone_number)
  end
end