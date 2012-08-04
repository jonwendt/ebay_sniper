class Notification
  include AuctionsHelper # For get_time_remaining
  
  def initialize
    @client ||= Twilio::REST::Client.new "ACea16f0f349ef99c4c11c216735185678", "fb79bb560d3ab40a659d012e75371583"
  end
  
  # Parses the SMS message from the user to perform the appropriate action.
  def read_sms(body, user_id)
    # If the user types help anywhere, return the help message.
    if body.downcase.match(/help/)
      return ["To change an auction, reply with COMMAND,ITEM ID,AMOUNT (if necessary), separated by commas." +
        " To change a bid, use the BID command, to change the lead time, use",
        "the LEAD command, with the amount being the time (in seconds). To cancel a snipe, use CANCEL,ITEM ID." +
        " To get auction information use INFO,ITEM ID."]
    elsif body.downcase.match(/bid/)    
      # If the user types bid, try to change the auction's max bid. If there's an error, return the error message.
      begin
        body = body.split(",")
        @auction = Auction.where(:item_id => body[1], :user_id => user_id).first
        @auction.update_attributes :max_bid => body[2].match(/\d+/).to_s.to_i
        return "Your max bid for the auction \"#{@auction.item[:get_item_response][:item][:title][0,97]}\"" +
          " has been changed to #{@auction.max_bid.to_s[0,10]}."
      rescue
        return "There was an error. Please reply with HELP if you need assistance."
      end
    # To impliment
    #elsif body.downcase.match(/lead/)
    #  begin
    #    body = body.split(",")
    #    @auction = Auction.where(:item_id => body[1], :user_id => user_id).first
    #    @auction.destroy
    #    return "The auction \"#{@auction.item[:get_item_response][:item][:title][0,97]}\" has been removed from your auction list."
    #  rescue
    #    return "There was an error. Please reply with HELP if you need assistance."
    #  end
    elsif body.downcase.match(/info/)
      # If the user types info, return the auction's title, price, max_bid, and time remaining.
      begin
        body = body.split(",")
        @auction = Auction.where(:item_id => body[1], :user_id => user_id).first
        @title = @auction.item[:get_item_response][:item][:title]
        if @title.length > 40
          @title = @title[0, 37] + "..."
        end
        return "The auction \"#{@title}\" has a current price of #{@auction.item[:get_item_response][:item][:selling_status][:current_price][0,15]}." +
          " Your max bid is #{@auction.max_bid.to_s[0,15]}. The auction ends in #{get_time_remaining @auction}."
      rescue
        return "There was an error. Please reply with HELP if you need assistance."
      end
    elsif body.downcase.match(/cancel/)
      # If the user types cancel, try to remove the appropriate auction.
      begin
        body = body.split(",")
        @auction = Auction.where(:item_id => body[1], :user_id => user_id).first
        @auction.destroy
        return "The auction \"#{@auction.item[:get_item_response][:item][:title][0,97]}\" has been removed from your auction list."
      rescue
        return "There was an error. Please reply with HELP if you need assistance."
      end
    else
      return "No command was detected. For help, reply with HELP."
    end
  end
  
  def send_sms(message, to)
    @client.account.sms.messages.create(
      :from => '+16023888925',
      :to => to,
      :body => message
    )
  end
  
  def build_sms(message)
    @xml = Twilio::TwiML::Response.new do |r|
      if message.respond_to?(:each)
        message.each do |sms|
          r.Sms sms
        end
      else
        r.Sms message
      end
    end
  end

end
