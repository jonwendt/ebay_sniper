class AddLeadTimeToAuctions < ActiveRecord::Migration
  def change
    add_column :auctions, :lead_time, :integer, :default => 0
  end
end
