class AuctionsController < ApplicationController
  before_filter :authenticate_user!#, :only => [:index, :show, :new, :edit, :create]

  # GET /auctions
  # GET /auctions.json
  def index
    if params[:status] == "All"
      @auctions = current_user.auctions
    else
      @auctions = sort_auctions(params[:status])
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
    @auction = update_auction(@auction)
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
    @auction.user = current_user
    
    # Parse the eBay item URL for the item's ID, then get the item's info
    @auction.item_id = self.parse_url_for_item_id(@auction.item_id)
    @auction.item = EbayAction.new.get_item(@auction.item_id, "")
    
    # If the auction is real
    if @auction.item[:get_item_response][:ack] == "Success"
      find_status(@auction)
    
      # Load the listing's pictures. If the item's seller didn't include a picture, load ebay's
      # default picture. Else, check if there are multiple pictures. If true, push them all into the
      # pictures array. If there's only one picture, then push that in.
      if @auction.item[:get_item_response][:item][:picture_details][:photo_display] == "None"
        @auction.picture.push "http://p.ebaystatic.com/aw/pics/nextGenVit/imgNoImg.gif"
      else
        @pictures = @auction.item[:get_item_response][:item][:picture_details][:picture_url]
        if @pictures.respond_to?(:each)
          @pictures.each do |picture|
            @auction.picture.push picture.to_s
          end
        else
          @auction.picture.push @pictures.to_s
        end
      end
    
      if @auction.auction_status == "Active"
        Resque.enqueue_at(
        self.get_enqueue_time(@auction.item[:get_item_response][:item][:listing_details][:end_time]).seconds.from_now,
                              AuctionBidder, @auction.id)
      end

      respond_to do |format|
        if @auction.save
          format.html { redirect_to edit_auction_path(@auction.id), notice: 'Auction was successfully created.' }
          format.json { render json: @auction, status: :created, location: @auction }
        else
          format.html { redirect_to new_auction_path, notice: "The auction's item ID was invalid." }
          format.json { render json: @auction.errors, status: :unprocessable_entity }
        end
      end
      
    # The auction does not exist. Redirect to new auction page.
    else
      redirect_to new_auction_path, notice: "The auction's item ID was invalid."
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

  def update_auction(auction)
    if auction.auction_status == "Active"
      # Sadly, this doesn't work because of the nested hashes.
      # auction.item.merge! EbayAction.new.get_item(auction.item_id, "timeleft,bidcount,currentprice,userid")
      
      # Figure out how to update while only grabbing values needed
      @new_auction = EbayAction.new.get_item(auction.item_id, "")
      auction.item = auction.item.merge @new_auction
      find_status(auction)
    end
    auction
  end
  
  # Finds the current status of the auction (active, won, lost, etc)
  def find_status(auction)
    # If the auction is over, check if we won or lost
    if auction.item[:get_item_response][:item][:time_left] == "PT0S"
      # Change current_user.name to wherever the user's ebay username is stored
      begin
        if auction.item[:get_item_response][:item][:selling_status][:high_bidder][:user_id] == "testuser_jpwendt2"
          auction.auction_status = "Won"
        else
          auction.auction_status = "Lost"
        end
      rescue
        auction.auction_status = "Lost"
      end
    else
      auction.auction_status = "Active"
    end
  end
  
  # Returns the appropriate auctions based on the user's selected auction status preference.
  def sort_auctions(status)
    @auctions = []
    # If the status == "Ended" return all Won, Lost, and Ended
    if status == "Ended"
      status = %w[Won Lost Ended]
      current_user.auctions.each do |auction|
        if status.include? auction.auction_status
          @auctions.push auction
        end
      end
    # If there was no status parameter for some reason, just display all
    elsif status == nil
      return current_user.auctions
    # Else, just match the status
    else
      current_user.auctions.each do |auction|
        if auction.auction_status == status.to_s
          @auctions.push auction
        end
      end
    end
    @auctions
  end
  
  # Extracts the item_id from the URL if the entry is not only digits. Otherwise, the entry is just returned.
  def parse_url_for_item_id(url)
    if url.match(/\D*/).to_s.length != 0
      @item_id = url.match(/item=\d*\D/).to_s.gsub!(/\D+/, "")
    else
      url
    end
  end
  
  # Calculates the time remaining on the auction minus 2 minutes
  def get_enqueue_time(auction_end_time)
    auction_end_time = Time.parse(auction_end_time).localtime
    return auction_end_time - Time.now - 120
  end
end
