class AddLimitToUsers < ActiveRecord::Migration
  def self.up
    add_column :users, :verified, :boolean, :null => false, :default => false
    add_column :users, :jump_limit, :integer, :null => false, :default => 100
  end

  def self.down
    remove_column :users, :jump_limit
    remove_column :users, :verified
  end
end
