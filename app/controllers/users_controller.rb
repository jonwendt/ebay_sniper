class UsersController < ApplicationController
  # GET /users
  # GET /users.json
  def index
    @users = User.all

    respond_to do |format|
      format.html # index.html.erb
      format.json { render json: @users }
    end
  end

  # GET /users/1
  # GET /users/1.json
  def show
    @user = User.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.json { render json: @user }
    end
  end

  # GET /users/new
  # GET /users/new.json
  def new
    @user = User.new

    respond_to do |format|
      format.html # new.html.erb
      format.json { render json: @user }
    end
  end

  # GET /users/1/edit
  def edit
    @user = User.find(params[:id])
  end

  # POST /users
  # POST /users.json
  def create
    @user = User.new(params[:user])

    respond_to do |format|
      if @user.save
        format.html { redirect_to @user, notice: 'User was successfully created.' }
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
    @user = User.find(params[:id])

    respond_to do |format|
      if @user.update_attributes(params[:user])
        format.html { redirect_to @user, notice: 'User was successfully updated.' }
        format.json { head :no_content }
      else
        format.html { render action: "edit" }
        format.json { render json: @user.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /users/1
  # DELETE /users/1.json
  def destroy
    @user = User.find(params[:id])
    @user.destroy

    respond_to do |format|
      format.html { redirect_to users_url }
      format.json { head :no_content }
    end
  end
  
  def get_time
    @user = User.find(params[:id])
    @action = "GeteBayOfficialTime"
    
    @client ||= Savon::Client.new do
     wsdl.endpoint = "https://api.sandbox.ebay.com/wsapi?siteid=0&routing=beta&callname=" + @action + "&version=423&appid=Leviona4d-c40e-454f-9d49-dd510693f96"
     wsdl.namespace = "urn:ebay:apis:eBLBaseComponents"
    end

    @response = @client.request @action + "Request" do
     soap.body = { "Version" => "423" }
     soap.input = @action + "Request", { "xmlns" => "urn:ebay:apis:eBLBaseComponents" }
     soap.header = { "ebl:RequesterCredentials" => { "ebl:eBayAuthToken" => "AgAAAA**AQAAAA**aAAAAA**n8gNUA**nY+sHZ2PrBmdj6wVnY+sEZ2PrA2dj6wFk4GhCZGGqQqdj6x9nY+seQ**194BAA**AAMAAA**RKYUL774WkhrRJGrHi1wS+VHDL2lOxG+Hoi9xx7Mm7jdbrh5BRv2UC93JN3Msn2EdwmnqhDwF2qxKFJYtY38YMMqKfpp+/GVB+WAta570T+LlCO5kKitdVTOal6EBhQRiMiKU9t7vGhTsi+ByQrShFpjH4Re3X6bQXNOGTjeWb1G+RdYOuH9NMELf7mVs6CBmWmhOdCuRow+Ekb/yVbGe1ZUfBcl55wYGI4AefPJTqoHgZuDEThrTeRs7TGFd3RaH5Cct+nMQrZRBEpUVeraUYEwCEct04qaRyfLm/EA4fvJcxp1znRr3BwGNwEam4OFeioQA4/bJMgmqU5eA8Unj8g7lLhYo2kWkspAG4aU5RkoFbMYctUDS2kSlQ3VtHJgmPwAHJVcPsWg2SO0B6Z+/SoPyToXiTFfNRSvgZXjxbzHmzringmRQ4yMwGdxDkD8rjFzTJTTCune42QH9WIqpjNPFwx+K3Y+V4qkPc2Q2b6VXQE/VOae0d5/4FrSQ8PMZB6SAbWSD/MfiX5ofpruOAHUGBG/9zpGXbPeESel2Jvv4DYpkRf0CLRiOAXrgW3PP1D1AnbHaVAR7PC/L9Lm0/BjJbWVlhKbaJyq/LIlv1JLwn4HInbWiR9XuXUGXshAGS+gZnGmzgNbAFllwT75opRiFdm2E1q4mOAntc9+1uviAYc5CxMs3igohPNut0JYdKDyQQyrGBOizIb1yM8kQRwfYiGRiTlyq/xrmkcjlK0+qM1dyFoaYaXvVQrh/sDc" }, :attributes! => { "ebl:RequesterCredentials" => { "xmlns:ebl" => "urn:ebay:apis:eBLBaseComponents"} } }
    end
    
    return @response
    
    respond_to do |format|
      format.html
    end
  end
end
