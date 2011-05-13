class AddScoreToCandies < ActiveRecord::Migration
  def self.up
    add_column :candies, :score, :integer, :null => false, :default => 0
  end

  def self.down
    remove_column :candies, :score
  end
end
