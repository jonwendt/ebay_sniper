module AuctionsHelper
  
  def get_time_remaining(auction)
    # Find the time remaining in seconds
    @time_left = (Time.parse(auction.item[:get_item_response][:item][:listing_details][:end_time]).localtime - Time.now).to_int
    if @time_left < 0
      return "0 seconds"
    end
    # Format the time
    mins = @time_left / 60
    hours = mins / 60
    days = hours / 24
    
    if days > 0
      "#{days}d #{hours % 24}h"
    elsif hours > 0
      "#{hours}h #{mins % 60}m"
    elsif mins > 0
      "#{mins}m #{@time_left % 24}s"
    elsif secs >= 0
      "#{@time_left} seconds"
    end
  end
end
