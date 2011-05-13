class AddRejectedToCandies < ActiveRecord::Migration
  def self.up
    add_column :candies, :rejected, :bool, :default => false
  end

  def self.down
    remove_column :candies, :rejected
  end
end
