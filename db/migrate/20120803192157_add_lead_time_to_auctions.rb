class AddLeadTimeToAuctions < ActiveRecord::Migration
  def change
    add_column :auctions, :lead_time, :integer
  end
end
