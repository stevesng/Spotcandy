class RemoveFlagFromCandies < ActiveRecord::Migration
  def self.up
    remove_column :candies, :flag
  end

  def self.down
    add_column :candies, :flag, :boolean
  end
end
