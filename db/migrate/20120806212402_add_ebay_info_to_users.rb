class AddEbayInfoToUsers < ActiveRecord::Migration
  def change
      add_column :users, :auth_token, :text, :null => false, :default => ""
      add_column :users, :auth_token_exp, :datetime, :null => false, :default => 1.minute.ago
      add_column :users, :username, :string
      add_column :users, :session_id, :string
  end
end