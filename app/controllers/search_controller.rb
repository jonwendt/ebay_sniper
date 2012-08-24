class SearchController < ApplicationController
  
  def new
    @auctions = Search.new.get_results(params[:search], current_user)
    
    respond_to do |format|
      format.html
      format.js
    end
  end
end