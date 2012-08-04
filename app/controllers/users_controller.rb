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
        format.html { redirect_to EbayAction.new.get_session_id, notice: 'User was successfully created.' }
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
  
  # Removes the user from OnlineUsers
  def sign_out
    OnlineUsers.remove current_user
  end
end
