class AddUserNotificationToAuction < ActiveRecord::Migration
  def change
    add_column :auctions, :user_notification, :string, :default => "Do not notify"
  end
end
