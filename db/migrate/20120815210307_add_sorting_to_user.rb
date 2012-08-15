class AddSortingToUser < ActiveRecord::Migration
  def change
    add_column :users, :preferred_status, :string, :default => "All"
    add_column :users, :preferred_sort, :string, :default => "title_asc"
  end
end
