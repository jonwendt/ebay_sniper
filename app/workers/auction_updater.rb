class AuctionUpdater
  @queue = :auction_updater
  
  # Updates each auction's info for every online user. If the auction has ended, update the status.
  def self.perform
    #$online_users.each do |user|
    User.all.each do |user|
      user.auctions.each do |auction|
        if auction.auction_status.to_s == "Active"
          #auction.item.merge! EbayAction.new.get_item(auction.item_id, "timeleft,bidcount,currentprice,userid")
          auction.item = EbayAction.new(user).get_item(auction.item_id, "")
          if auction.item[:get_item_response][:item][:time_left] == "PT0S"
            find_status(auction, user.username)
          end
          auction.save
          
          # If the item's current price is above max_bid, send notification to user.
          if auction.item[:get_item_response][:item][:selling_status][:current_price].to_i > auction.max_bid &&
          auction.user_notification == "Text Message" && user.phone_number != "" &&
          (auction.been_notified.gsub(/\A\d+/) != auction.id && auction.been_notified.gsub(/\Z\w+/ != "outbid")
            @title = auction.item[:get_item_response][:item][:title].to_s
            if @title.length > 38
              @title = @title[0,35] + "..."
            end
            @message = "You've been outbid for the item \"#{@title}\", ID: \"#{auction.item_id}\"." +
              " Would you like to change your max bid? For help, reply with HELP."
            Resque.enqueue(NotificationSender, auction.id, @message)
            auction.been_notified = auction.id + ",outbid"
          end
        end
      end
    end
  end
  
  def self.find_status(auction, username)
    # If the auction is over, check if we won or lost
    if auction.item[:get_item_response][:item][:time_left] == "PT0S"
      # Checks if the highest bidder's username is the user's username
      if auction.item[:get_item_response][:item][:selling_status][:high_bidder][:user_id] == username
        auction.auction_status = "Won"
      else
        auction.auction_status = "Lost"
      end
    else
      auction.auction_status = "Active"
    end
  end
end