class AddFlagStatusToCandies < ActiveRecord::Migration
  def self.up
    add_column :candies, :flag_status, :integer, :null => false, :default => 0
  end

  def self.down
    remove_column :candies, :flag_status
  end
end
