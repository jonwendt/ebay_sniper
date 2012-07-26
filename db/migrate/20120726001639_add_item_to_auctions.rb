class AddItemToAuctions < ActiveRecord::Migration
  def change
    add_column :auctions, :item, :text
  end
end
