class AuctionsController < ApplicationController
  before_filter :authenticate_user!#, :only => [:index, :show, :new, :edit, :create]

  # GET /auctions
  # GET /auctions.json
  def index
    if params[:status] != nil
      current_user.update_attributes :preferred_status => params[:status]
    end
    if params[:sort] != nil
      current_user.update_attributes :preferred_sort => params[:sort]
    end
    @auctions = Auction.sort_auctions(current_user)

    respond_to do |format|
      format.html
      format.json { render json: @auctions }
      format.js { render :layout => false }
    end
  end

  # GET /auctions/new
  # GET /auctions/new.json
  def new
    @auction = Auction.new

    respond_to do |format|
      format.html
      format.json { render json: @auction }
    end
  end

  # GET /auctions/1/edit
  def edit
    @auction = Auction.find(params[:id])
    @picture_id = params[:pic].to_i

    respond_to do |format|
      format.html
      format.js { render :layout => false }
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
        format.html { redirect_to edit_auction_path(@auction.id), notice: 'Auction was successfully created.' }
        format.js
        format.json { render json: @auction, status: :created, location: @auction }
      else
        format.html { render action: 'new' }
        format.js
        format.json { render json: @auction.errors.full_messages }
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
        format.html { render action: 'edit' }
        format.json { render json: @auction.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /auctions/1
  # DELETE /auctions/1.json
  def destroy
    @auction = Auction.find(params[:id])
    @auction.remove_auction

    respond_to do |format|
      format.html { redirect_to auctions_url }
      format.json { head :no_content }
    end
  end

  # Restores a deleted auction
  def restore
    @auction = Auction.find(params[:id])
    @auction.auction_status = 'Active' # So find_status won't ignore it. --- @auction.activate!
    @auction.update_auction
    @auction.enqueue_job

    redirect_to edit_auction_path, notice: 'Auction was successfully restored.'
  end

  def remove_multiple
    Auction.remove_multiple params[:auction_ids]

    redirect_to auctions_path
    
    # respond_to do |format|
    #   format.js
    # end
  end
  
  def restore_multiple
    Auction.restore_multiple params[:auction_ids]

    redirect_to auctions_path 

    # respond_to do |format|
    #   format.js
    # end
  end

  # POST /auctions
  # POST /auctions.json
  def create_multiple
    # Get the checked auctions
    @auctions = Auction.prepare_multiple params[:auction], current_user

    # If there are errors, re-render the page and show the auctions with errors. Else, show auctions#index.
    if @auctions.detect { |a| not a.errors.empty? }
      respond_to do |format|
        format.html { render 'import' }
      end
    else
      respond_to do |format|
        format.html { redirect_to auctions_path }
      end
    end
  end

  def import
    @auctions = EbayAction.new(current_user).import

    respond_to do |format|
      format.html
    end
  end

  def update_info
    @auction = Auction.find(params[:id])
    @auction.update_auction

    redirect_to edit_auction_path
  end
end