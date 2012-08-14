class AuctionUpdater
  @queue = :auction_updater
  
  # Updates each auction's info for every online user. If the auction has ended, update the status.
  def self.perform
    User.currently_online.each do |user|
      user.auctions.each do |auction|
        auction.update_auction
        
        if auction.auction_status == "Active"
          # --------------- Active Auction Notifications --------------- #
          # If the item's current price is above max_bid, and the user wishes to be notified about auction updates, but
          # hasn't yet received an update regarding this issue, send notification to user.
          if auction.item[:get_item_response][:item][:selling_status][:converted_current_price].to_f > auction.max_bid &&
          auction.user_notification == "Text Message" && auction.been_notified.split(",")[0] != auction.id &&
          auction.been_notified.split(",")[1] != "outbid"
            title = auction.item[:get_item_response][:item][:title].to_s
            if title.length > 38
              title = title[0,35] + "..."
            end
            message = "You've been outbid for the item \"#{title}\", ID: \"#{auction.item_id}\"." +
              " Would you like to change your max bid? For help, reply with HELP."
            Resque.enqueue(NotificationSender, auction.id, message)
            auction.been_notified = auction.id.to_s + ",outbid"
            auction.save
          end
        end
      end
    end
  end
end