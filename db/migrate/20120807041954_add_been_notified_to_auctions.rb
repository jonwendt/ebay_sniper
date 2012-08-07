class AddBeenNotifiedToAuctions < ActiveRecord::Migration
  def change
    add_column :auctions, :been_notified, :string
  end
end
