class NotificationSender
  @queue = :notification_sender
  
  def self.perform(auction_id, message)
    auction = Auction.find(auction_id)
    user = auction.user
    if auction.user_notification == "Text Message" && auction.user.phone_number != "" && auction.user.phone_number != nil
      Notification.new.send_sms(message, user.phone_number)
    end
  end
end