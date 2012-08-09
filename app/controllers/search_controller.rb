class SearchController < ApplicationController
  
  def new
    @search = params[:search]
    @auctions = @auction = Auction.where(:item_id => @search)
    @auctions ||= []
    
    respond_to do |format|
      format.html
    end
  end
end