class NotificationsController < ApplicationController
  
  # GET /notifications/receive
  # GET /notifications/receive.xml
  def receive
    @notification = Notification.new
    
    @user = User.where(:phone_number => params['From']).first
    # If there is no user account with the phone number
    if @user == []
      @xml = @notification.build_sms "This phone number is not associated with any user account for Levion's eBay Sniper. Please register an account or add this phone number to your current account."
    
    # If there is a user, try to parse their text and see if it merits action and a response
    else
      @response_text = @notification.read_sms(params['Body'], @user.id)
    
      # If the user should be sent back a reply, build them the appropriate reply (as determined by read_sms)
      if @response_text != nil
        @xml = @notification.build_sms @response_text
      else
      # Don't send a response
        return
      end
    end
    
    # Builds the reply in XML, which Twilio sends back to the user.
    respond_to do |format|
      #format.html # new.html.erb
      format.xml { render xml: @xml.text }
    end
  end
  
end