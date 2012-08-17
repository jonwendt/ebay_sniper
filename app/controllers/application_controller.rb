class ApplicationController < ActionController::Base
  protect_from_forgery
  
  before_filter :update_onlineness
  
  def update_onlineness
    if self.current_user
      $redis.setex("ebaysniper:online_users:#{self.current_user.id}", 1.hour.to_i, "1")
      # Check user's consent_failed column (set to true in EbayAction when the auth_token is expired)
      #if self.consent_failed?
      #  redirect_to consent_failed_path
      #end
    end
  end
  
end
