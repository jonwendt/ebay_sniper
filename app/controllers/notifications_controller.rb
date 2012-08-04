class NotificationsController < ApplicationController
  
  # GET /notifications/receive
  # GET /notifications/receive.xml
  def receive
    @notification = Notification.new
    
    @user = User.where(:phone_number => params['From']).first
    # If there is no user account with the phone number
    if @user == []
      @xml = @notification.build_sms "This phone number is not associated with any user account for Levion's eBay Sniper. Please register an account or add this phone number to your current account."
    else
      # If there is a user, try to parse their text and generate a response
      @response_text = @notification.read_sms(params['Body'], @user.id)
      @xml = @notification.build_sms @response_text
    end
    
    # Builds the reply in XML, which Twilio sends back to the user.
    respond_to do |format|
      format.xml { render xml: @xml.text }
    end
  end
  
end