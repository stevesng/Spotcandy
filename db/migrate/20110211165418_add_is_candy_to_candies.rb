class AddIsCandyToCandies < ActiveRecord::Migration
  def self.up
    add_column :candies, :is_candy, :bool, :default => false
  end

  def self.down
    remove_column :candies, :is_candy
  end
end
