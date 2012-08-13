class AuctionsController < ApplicationController
  before_filter :authenticate_user!#, :only => [:index, :show, :new, :edit, :create]

  # GET /auctions
  # GET /auctions.json
  def index
    @auctions = Auction.sort_auctions(params[:status], params[:sort], current_user)

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
    @auction.prepare
    @picture_id = params[:pic].to_i
    
    respond_to do |format|
      format.html
      format.js
    end
  end

  # POST /auctions
  # POST /auctions.json
  def create
    @auction = Auction.new(params[:auction])
    @auction.user = self.current_user

    respond_to do |format|
      if @auction.save
        # Needs to be enqueued after save so auction has ID
        @auction.enqueue_job
        format.html { redirect_to edit_auction_path(@auction.id), notice: "Auction was successfully created." }
        format.json { render json: @auction, status: :created, location: @auction }
      else
        format.html { render action: "new" }
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
    @auction.update_attributes :auction_status => "Deleted"

    respond_to do |format|
      format.html { redirect_to auctions_url + "?status=All" }
      format.json { head :no_content }
    end
  end
  
  # Doesn't work yet. Want to pass in all checkbox values. Checkboxes that are checked with have the auction with their id deleted.
  def remove_multiple
    @auctions = Auction.find(params[:auction_ids])
    @auctions.each do |auction|
      auction.update_attributes!(params[:auction].reject { |k,v| v.blank? })
    end
  end
  
  def restore
    @auction = Auction.find(params[:id])
    Resque.remove_delayed(AuctionBidder, @auction.id)
    @auction.auction_status = "Active" # So find_status won't ignore it.
    @auction.find_status
    
    respond_to do |format|
      if @auction.save
        format.html { redirect_to edit_auction_path, notice: 'Auction was successfully restored.' }
      else
        format.html { render action: "edit" }
      end
    end
  end
end