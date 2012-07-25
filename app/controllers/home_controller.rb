class HomeController < ApplicationController
  before_filter :authenticate_user!, :only => [:index, :show]
  
  def index
    respond_to do |format|
      format.html
    end
  end
  
  def show
    @item = get_item
  end
  
  def get_item
    @item = EbayAction.new.get_item(params[:item_id])
    
    respond_to do |format|
      format.html
    end
  end

  def place_bid
    @item = EbayAction.new.place_bid(params[:item_id], params[:amount])
    
    respond_to do |format|
      format.html
    end
  end
  
end