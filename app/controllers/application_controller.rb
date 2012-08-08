class ApplicationController < ActionController::Base
  protect_from_forgery
  
  before_filter :update_onlineness
  
  def update_onlineness
    if self.current_user
      $redis.setex("ebaysniper:online_users:#{self.current_user.id}", 1.hour.to_i, "1")
    end
  end
  
end
