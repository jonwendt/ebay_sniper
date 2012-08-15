class Search

  def get_results(search)
    search = search.to_s.downcase.split(" ")
    unless search == ""
      @auctions = Auction.select { |a| search.any?{ |w| a.item[:get_item_response][:item][:title].to_s.downcase.include? w } }
      @auctions += Auction.select { |a| search.any?{ |w| a.item[:get_item_response][:item][:description].to_s.downcase.include? w } }
      @auctions += Auction.select { |a| search.any?{ |w| a.item[:get_item_response][:item][:selling_status][:converted_current_price].to_s.downcase.include? w } }
      @auctions += Auction.select { |a| search.any?{ |w| a.max_bid.to_s.downcase.include? w } }
      @auctions += Auction.select { |a| search.any?{ |w| a.item_id.to_s.downcase.include? w } }
      @auctions.uniq!
      @auctions = @auctions.sort_by { |a| [a.item[:get_item_response][:item][:title]] }
    end
    @auctions ||= []
  end
end