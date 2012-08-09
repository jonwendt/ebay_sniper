class UsersController < Devise::RegistrationsController
  
  # GET /users
  # GET /users.json
  def index
    super
  end

  # GET /users/1
  # GET /users/1.json
  def show
    super
  end

  # GET /users/new
  # GET /users/new.json
  def new
    super
  end

  # GET /users/1/edit
  def edit
    super
  end

  # POST /users
  # POST /users.json
  def create
    @user = User.new(params[:user])

    respond_to do |format|
      if @user.save
        format.html { redirect_to EbayAction.new(@user).get_session_id, notice: 'User was successfully created.' }
        format.json { render json: @user, status: :created, location: @user }
      else
        format.html { render action: "new" }
        format.json { render json: @user.errors, status: :unprocessable_entity }
      end
    end
  end

  # PUT /users/1
  # PUT /users/1.json
  def update
    super
  end

  # DELETE /users/1
  # DELETE /users/1.json
  def destroy
    super
  end
  
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
      redirect_to new_user_session_path
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
