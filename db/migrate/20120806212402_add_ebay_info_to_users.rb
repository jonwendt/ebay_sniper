class AddEbayInfoToUsers < ActiveRecord::Migration
  def change
      add_column :users, :auth_token, :text
      add_column :users, :auth_token_exp, :datetime
      add_column :users, :username, :string
      add_column :users, :session_id, :string
  end
end
