class UpdateAuctions
  @queue = :update_auctions
  
  # Updates each auction's info for every online user. If the auction has ended, update the status.
  def self.perform
    OnlineUsers.users.each do |user|
      user.auctions.each do |auction|
        if auction.auction_status == "Active"
          #auction.item.merge! EbayAction.new.get_item(auction.item_id, "timeleft,bidcount,currentprice,userid")
          auction.item = EbayAction.new.get_item(auction.item_id, "")
          if auction.item[:get_item_response][:item][:time_left] == "PT0S"
            auction.find_status(auction)
          end
        end
      end
    end
  end
end