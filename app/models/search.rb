class Search

  def get_results(search, current_user)
    search = search.to_s.downcase.split(" ")
    unless search == ""
      auctions = Auction.select { |a| a.user_id == current_user.id && search.any? { |word|
        a.item[:get_item_response][:item][:title].to_s.downcase.include?(word) ||
        a.item[:get_item_response][:item][:description].to_s.downcase.include?(word) ||
        a.item[:get_item_response][:item][:selling_status][:converted_current_price].to_s.downcase.include?(word) ||
        a.max_bid.to_s.downcase.include?(word) ||
        a.item_id.to_s.downcase.include?(word)
      } }
      auctions.uniq!
      auctions = auctions.sort_by { |a| [a.item[:get_item_response][:item][:title]] }
    end
    auctions ||= []
  end
end