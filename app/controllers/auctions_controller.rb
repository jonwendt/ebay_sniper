class AuctionsController < ApplicationController
  before_filter :authenticate_user!#, :only => [:index, :show, :new, :edit, :create]

  # GET /auctions
  # GET /auctions.json
  def index
    @auctions = current_user.auctions

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
    @auction.user = current_user
    
    # Parse the eBay item URL for the item's ID, then get the item's info
    @auction.item_id = self.parse_url_for_item_id(@auction.item_id)
    @auction.item = EbayAction.new.get_item(@auction.item_id)
    
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

    respond_to do |format|
      if @auction.save
        format.html { redirect_to @auction, notice: 'Auction was successfully created.' }
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
        format.html { redirect_to @auction, notice: 'Auction was successfully updated.' }
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
    @auction.destroy

    respond_to do |format|
      format.html { redirect_to auctions_url }
      format.json { head :no_content }
    end
  end
  
  # Extracts the item_id from the URL
  def parse_url_for_item_id(url)
    @item_id = url.match(/item=\d*\D/).to_s.gsub!(/\D+/, "")
  end
end
