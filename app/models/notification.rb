class Notification# < ActiveRecord::Base
  # attr_accessible :title, :body
  
  def initialize
    @client ||= Twilio::REST::Client.new "ACea16f0f349ef99c4c11c216735185678", "fb79bb560d3ab40a659d012e75371583"
  end
  
  def read_sms(body)
    if body.to_s.match(/"yes"/)
      @message = body.to_s.match(/\d*/)
      if @message.empty?
        return nil
      else
        return @message
      end
    else
      return nil
    end
  end
  
  def send_sms(message, to)
    to = '+16027383570'
    @client.account.sms.messages.create(
      :from => '+16023888925',
      :to => to,
      :body => message
    )
  end
  
  def build_sms(message)
    @response = Twilio::TwiML::Response.new do |r|
      r.Sms message
    end
  end
end
