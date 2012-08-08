class SessionsController < Devise::SessionsController
  before_filter :cleanup_onlineness, :only => [:destroy]
  
  def cleanup_onlineness
    if self.current_user
      $redis.del("ebaysniper:online_users:#{self.current_user.id}")
    end
  end
  
end