class Notification# < ActiveRecord::Base
  # attr_accessible :title, :body
  
  def initialize
    @client ||= Twilio::REST::Client.new "ACea16f0f349ef99c4c11c216735185678", "fb79bb560d3ab40a659d012e75371583"
  end
  
  def read_sms
    @client.account.sms
  end
  
  def build_sms
    @response = Twilio::TwiML::Response.new do |r|
      r.Sms "Thanks for trying out Levion's eBay sniper!"
    end
  end
end
