class UsersController < Devise::RegistrationsController
  
  def add_token
    # Using rescue to make sure user doesn't stumble upon this without using the correct parameters.
    begin
      # Use the session_id to fetch the user's auth token and username and save those values
      @user = User.find(params[:user_id])
      @user.username = params[:username]
      EbayAction.new(@user).fetch_token
    rescue
      # If the user_id doesn't exist, do nothing
    end
      redirect_to root_path
  end
  
  def consent_failed
    @user = User.find(params[:user_id])
    @consent_url = EbayAction.new(@user).get_session_id
  end
  
  def check_token
    # Not sure how to override devise new session method to pass params, so assigning user to current_user. Using rescue as authenticate_user!
    begin
      @user = current_user
      if @user.auth_token == nil || @user.auth_token_exp < Time.now
        redirect_to user_consent_failed_path + "?user_id=#{@user.id}"
      else
        redirect_to root_path
      end
    rescue
      redirect_to new_user_session_path
    end
  end
  
end
