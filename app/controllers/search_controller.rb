class SearchController < ApplicationController
  
  def new
    @search = params[:search].to_s.downcase
    unless @search = ""
      @auctions = Auction.select{ |a| a.item.to_s.downcase.include? @search}
    end
    @auctions ||= []
    
    respond_to do |format|
      format.html
    end
  end
end