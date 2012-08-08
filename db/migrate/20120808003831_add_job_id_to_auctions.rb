class AddJobIdToAuctions < ActiveRecord::Migration
  def change
    add_column :auctions, :job_id, :string
  end
end
