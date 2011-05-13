class AddFlagToCandies < ActiveRecord::Migration
  def self.up
    add_column :candies, :flag, :bool, :default => false
  end

  def self.down
    remove_column :candies, :flag
  end
end
