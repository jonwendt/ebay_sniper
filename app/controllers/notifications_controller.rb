class NotificationsController < ApplicationController
  
  # POST /notifications/receive
  # POST /notifications/receive.xml
  def receive
    @notification = Notification.new
    @sms = @notification.read_sms(params[:Body])
    if @sms != nil
      # Do something with sms
      @response = @notification.send_sms "Your max bid was changed to " + @sms, params[:From]
    else  
      #@response = @notification.send_sms "Your max bid was not changed.", params[:From]
    end
    
    #respond_to do |format|
    #  format.html # new.html.erb
    #  format.xml { render xml: @response.text }
    #end
  end
  
end
