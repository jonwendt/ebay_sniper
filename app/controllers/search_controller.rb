class SearchController < ApplicationController
  before_filter :authenticate_user!
  
  def index
    @auctions = Search.new.get_results(params[:search], current_user)
    
    respond_to do |format|
      format.html
    end
  end
end