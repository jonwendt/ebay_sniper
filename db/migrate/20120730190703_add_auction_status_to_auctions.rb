class AddAuctionStatusToAuctions < ActiveRecord::Migration
  def change
    add_column :auctions, :auction_status, :string
  end
end
