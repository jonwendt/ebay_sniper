class Notification# < ActiveRecord::Base
  # attr_accessible :title, :body
  
  def initialize
    @client ||= Twilio::REST::Client.new "ACea16f0f349ef99c4c11c216735185678", "fb79bb560d3ab40a659d012e75371583"
  end
  
  # Parses the SMS message from the user to perform the appropriate action.
  def read_sms(body, user_id)
    # If the user types help anywhere, return the help message.
    if body.downcase.match(/help/)
      return ["To change an auction, reply with COMMAND,ITEM ID,AMOUNT (if necessary), separated by commas. To change a bid," +
        " use the BID command, to change the lead time, use", "the LEAD command, with the amount being the time (in seconds)." +
        " To cancel a snipe, use CANCEL,ITEM ID. To get auction information use INFO,ITEM ID."]
      
    # If the user types bid, try to change the auction's max bid. If there's an error, return the error message.
    elsif body.downcase.match(/bid/)
      @test
      begin
        body = body.split(",")
        @auction = Auction.where(:item_id => body[1], :user_id => user_id).first
        @auction.update_attributes :max_bid => body[2].match(/\d+/).to_s.to_i
        return "Your max bid for the auction \"#{@auction.item[:get_item_response][:item][:title][0,97]}\" has been changed to #{@auction.max_bid.to_s[0,10]}."
      rescue
        return "There was an error. Please reply with HELP if you need assistance."
      end
    else
      return nil
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
