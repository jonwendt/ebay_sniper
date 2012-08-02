class AddUserNotificationToAuction < ActiveRecord::Migration
  def change
    add_column :auctions, :user_notification, :string
  end
end
