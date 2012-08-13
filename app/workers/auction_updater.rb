class AuctionUpdater
  @queue = :auction_updater
  
  # Updates each auction's info for every online user. If the auction has ended, update the status.
  def self.perform
    User.currently_online.each do |user|
      user.auctions.each do |auction|
        if auction.auction_status.to_s == "Active"
          auction.item = EbayAction.new(user).get_item(auction.item_id, nil)
          if auction.item[:get_item_response][:item][:time_left] == "PT0S"
            # Send a notification to the user saying if they won or lost the auction.
            auction.find_status
            if auction.auction_status == "Won"
              #message = "Congratulations! You won the auction for \"#{auction.item[:get_item_response][:item][:title][0,113]}\"! :)"
            else
              #message = "Sorry, but you have lost the auction for \"#{auction.item[:get_item_response][:item][:title][0,113]}\". :("
            end
            Resque.enqueue(NotificationSender, auction.id, message)
            auction.been_notified = auction.id.to_s + ",#{auction.auction_status.downcase}"
          end
          
          # --------------- Active Auction Notifications --------------- #
          # If the item's current price is above max_bid, and the user wishes to be notified about auction updates, but
          # hasn't yet received an update regarding this issue, send notification to user.
          if auction.item[:get_item_response][:item][:selling_status][:converted_current_price].to_f > auction.max_bid &&
          auction.user_notification == "Text Message" && auction.user.phone_number != "" &&
          auction.been_notified.to_s.split(",")[0] != auction.id && auction.been_notified.to_s.split(",")[1] != "outbid"
            title = auction.item[:get_item_response][:item][:title].to_s
            if title.length > 38
              title = title[0,35] + "..."
            end
            message = "You've been outbid for the item \"#{title}\", ID: \"#{auction.item_id}\"." +
              " Would you like to change your max bid? For help, reply with HELP."
            Resque.enqueue(NotificationSender, auction.id, message)
            auction.been_notified = auction.id.to_s + ",outbid"
          end
          auction.save
        end
      end
    end
  end
end