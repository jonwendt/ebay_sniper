class AuctionsController < ApplicationController
  before_filter :authenticate_user!#, :only => [:index, :show, :new, :edit, :create]

  # GET /auctions
  # GET /auctions.json
  def index
    if params[:status] == "All"
      @auctions = current_user.auctions
    else
      @auctions = Auction.sort_auctions(params[:status], current_user)
    end

    respond_to do |format|
      format.html # index.html.erb
      format.json { render json: @auctions }
    end
  end

  # GET /auctions/1
  # GET /auctions/1.json
  def show
    @auction = Auction.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.json { render json: @auction }
    end
  end

  # GET /auctions/new
  # GET /auctions/new.json
  def new
    @auction = Auction.new

    respond_to do |format|
      format.html # new.html.erb
      format.json { render json: @auction }
    end
  end

  # GET /auctions/1/edit
  def edit
    @auction = Auction.find(params[:id])
    @auction.update_auction @auction
    @picture_id = params[:pic].to_i
    
    respond_to do |format|
      format.html
      format.js { render 'auction' }
    end
  end

  # POST /auctions
  # POST /auctions.json
  def create
    @auction = Auction.new(params[:auction])
    @auction.prepare @auction, current_user

    respond_to do |format|
      if @auction.save
        format.html { redirect_to edit_auction_path(@auction.id), notice: "Auction was successfully created." }
        format.json { render json: @auction, status: :created, location: @auction }
      else
        format.html { render action: "new" }#redirect_to new_auction_path, notice: @auction.errors }#"The auction's item ID was invalid." }
        format.json { render json: @auction.errors, status: :unprocessable_entity }
      end
    end
  end

  # PUT /auctions/1
  # PUT /auctions/1.json
  def update
    @auction = Auction.find(params[:id])

    respond_to do |format|
      if @auction.update_attributes(params[:auction])
        format.html { redirect_to edit_auction_path, notice: 'Auction was successfully updated.' }
        format.json { head :no_content }
      else
        format.html { render action: "edit" }
        format.json { render json: @auction.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /auctions/1
  # DELETE /auctions/1.json
  def destroy
    @auction = Auction.find(params[:id])
    Resque.remove_delayed(AuctionBidder, @auction.id)
    @auction.destroy

    respond_to do |format|
      format.html { redirect_to auctions_url + "?status=All" }
      format.json { head :no_content }
    end
  end
end
