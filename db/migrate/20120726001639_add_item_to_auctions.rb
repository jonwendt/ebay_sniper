class AddItemToAuctions < ActiveRecord::Migration
  def change
    add_column :auctions, :item, :binary
  end
end
