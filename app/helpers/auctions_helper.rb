module AuctionsHelper
  
  def get_time_remaining(auction)
    Time.parse(auction.item[:get_item_response][:item][:listing_details][:end_time]).localtime
  end
end
