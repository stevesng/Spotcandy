class AddCandyNotificationToUsers < ActiveRecord::Migration
  def self.up
    add_column :users, :notify_candy, :boolean, :null => false, :default => true
  end

  def self.down
    remove_column :users, :notify_candy
  end
end
