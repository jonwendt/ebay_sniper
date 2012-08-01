class HomeController < ApplicationController
  
  def index
    respond_to do |format|
      format.html
    end
  end
  
  # This method is only called when the user logs in. It will add the user's auctions to the update_auctions worker.
  def login
    OnlineUsers.users.push(current_user)
    $online_users.push(current_user)
    redirect_to home_index_path
  end
end