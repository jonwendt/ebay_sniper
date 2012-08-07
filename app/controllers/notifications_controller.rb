class NotificationsController < ApplicationController
  
  # GET /notifications/receive
  # GET /notifications/receive.xml
  def receive
    @xml = Notification.new.respond params['From'], params['Body']
    
    # Builds the reply in XML, which Twilio sends back to the user.
    respond_to do |format|
      format.xml { render xml: @xml.text }
    end
  end
  
end