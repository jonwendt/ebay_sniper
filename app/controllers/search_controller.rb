class SearchController < ApplicationController
  
  def new
    @auctions = Search.new.get_results(params[:search])
    
    respond_to do |format|
      format.html
      format.js
    end
  end
end