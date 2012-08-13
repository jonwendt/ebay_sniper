class AddPictureToAuctions < ActiveRecord::Migration
  def change
    add_column :auctions, :picture, :text
  end
end
