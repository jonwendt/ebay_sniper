class NotificationsController < ApplicationController
  
  # GET /notifications/receive
  # GET /notifications/receive.xml
  def receive
  	begin
      xml = Notification.new.respond params['From'], params['Body']
    
      # Builds the reply in XML, which Twilio sends back to the user.
      respond_to do |format|
        format.xml { render xml: xml.text }
      end
  	rescue
  	  redirect_to root_path
  	end
  end
  
end