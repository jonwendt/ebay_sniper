class CreateAuctions < ActiveRecord::Migration
  def change
    create_table :auctions do |t|
      t.string :item_id
      t.integer :user_id
      t.integer :max_bid

      t.timestamps
    end
  end
end
