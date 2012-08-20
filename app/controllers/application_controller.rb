class ApplicationController < ActionController::Base
  protect_from_forgery
  
  before_filter :update_onlineness
  
  def update_onlineness
    if self.current_user
      $redis.setex("ebay_sniper:online_users:#{self.current_user.id}", 1.hour.to_i, "1")
      
      # Check if the user's auth_token is expired. If so, redirect to consent_failed page.
      if self.current_user.consent_failed? && params[:action] != "add_token"
        self.current_user.update_attributes :auth_token_exp => 1.second.from_now
        redirect_to user_consent_failed_path(:user_id => current_user.id)
      end
    end
  end
  
end
