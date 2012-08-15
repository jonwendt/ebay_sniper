class SearchController < ApplicationController
  
  def new
    search = params[:search].to_s.downcase
    unless search == ""
      @auctions = Auction.select { |a| a.item[:get_item_response][:item][:title].to_s.downcase.include? search }
      @auctions += Auction.select { |a| a.item[:get_item_response][:item][:description].to_s.downcase.include? search }
      @auctions += Auction.select { |a| a.item[:get_item_response][:item][:selling_status][:converted_current_price].to_s.downcase.include? search }
      @auctions += Auction.select { |a| a.max_bid.to_s.downcase.include? search }
      @auctions += Auction.select { |a| a.item_id.to_s.downcase.include? search }
      @auctions.uniq!
    end
    @auctions ||= []
    
    respond_to do |format|
      format.html
      format.js
    end
  end
end